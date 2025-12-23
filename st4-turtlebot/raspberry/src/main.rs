use cdr::{
    CdrLe, 
    Infinite
};

use hls_lfcd_lds_driver::{
    LFCDLaser, 
    LaserReading,
    DEFAULT_BAUD_RATE, 
    DEFAULT_PORT
};

use serde::{
    Deserialize, 
    Serialize
};

use std::{
    f32::consts::PI,
    time::SystemTime
};

use zenoh::{
    config::Config,
    prelude::r#async::AsyncResolve
};

#[derive(Debug, Serialize, Deserialize, Clone)]
struct Time {
    sec: u32,
    nsec: u32,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
struct Header {
    stamp: Time,
    frame_id: String,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
struct LaserScan {
    header: Header,
    angle_min: f32,
    angle_max: f32,
    angle_increment: f32,
    time_increment: f32,
    scan_time: f32,
    range_min: f32,
    range_max: f32,
    ranges: Vec<f32>,
    intensities: Vec<f32>,
}

impl From<LaserReading> for LaserScan {
    fn from(lr: LaserReading) -> Self {
        let now = SystemTime::now()
            .duration_since(SystemTime::UNIX_EPOCH)
            .unwrap();
        LaserScan {
            header: Header {
                stamp: Time {
                    sec: now.as_secs() as u32,
                    nsec: now.subsec_nanos() as u32,
                },
                frame_id: "laser".to_string(),
            },
            angle_increment: (2.0 * PI / 360.0),
            angle_min: 0.0,
            angle_max: 2.0 * PI - (2.0 * PI / 360.0),
            time_increment: 1.0 / (lr.rpms as f32 * 6.0),
            scan_time: 1.0 / (lr.rpms as f32 * 6.0) * 360.0,
            range_min: 0.12,
            range_max: 3.5,
            ranges: lr.ranges.map(|r| r as f32 / 1000.0).to_vec(),
            intensities: lr.intensities.map(|r| r as f32).to_vec(),
        }
    }
}

#[async_std::main]
async fn main() {
    env_logger::init();

    let (config, key, port, baud_rate, delay) = get_config();
    println!("Opening LDS01 on {} with {}", port, baud_rate);

    let mut port = LFCDLaser::new(port, baud_rate).unwrap();

    println!("Opening session...");
    let session = zenoh::open(config).res().await.unwrap();

    let publisher = session.declare_publisher(key).res().await.unwrap();
    loop {
        let laser_scan: LaserScan = port.read().await.unwrap().into();
        
        publisher
            .put(cdr::serialize::<_, _, CdrLe>(&laser_scan, Infinite).unwrap())
            .res()
            .await
            .unwrap();
        async_std::task::sleep(std::time::Duration::from_millis(delay)).await;
    }
}

fn get_config() -> (Config, String, String, u32, u64) {
    let config = Config::from_file("config_lidar.json").unwrap();

    let key = "turtle/lidar".to_string();
    let port = DEFAULT_PORT.to_string();
    let baud_rate: u32 = DEFAULT_BAUD_RATE.parse().unwrap();
    let delay: u64 = 40;

    (config, key, port, baud_rate, delay)
}
