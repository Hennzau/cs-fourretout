library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

entity cpu is
    port (
        MAX10_CLK1_50 : in std_logic;

        KEY : in std_logic_vector(1 downto 0);

        SW   : in std_logic_vector(9 downto 0);
        LEDR : out std_logic_vector(9 downto 0);

        HEX0 : out std_logic_vector(7 downto 0);
        HEX1 : out std_logic_vector(7 downto 0);
        HEX2 : out std_logic_vector(7 downto 0);
        HEX3 : out std_logic_vector(7 downto 0);
        HEX4 : out std_logic_vector(7 downto 0);
        HEX5 : out std_logic_vector(7 downto 0)
    );
end cpu;

architecture Behavioral of cpu is
    component pcounter
        port (
            en  : in std_logic;
            clk : in std_logic;
            rst : in std_logic;

            jump : in std_logic;

            address_in  : in std_logic_vector(7 downto 0);
            address_out : out std_logic_vector(7 downto 0)
        );
    end component;

    component rom
        port (
            en  : in std_logic;
            clk : in std_logic;
            rst : in std_logic;

            address : in std_logic_vector(7 downto 0);

            data : out std_logic_vector(25 downto 0)
        );
    end component;

    component ram
        port (
            rw  : in std_logic;
            en  : in std_logic;
            clk : in std_logic;
            rst : in std_logic;

            address : in std_logic_vector(7 downto 0);

            data_in  : in std_logic_vector(7 downto 0);
            data_out : out std_logic_vector(7 downto 0)
        );
    end component;

    component alu
        port (
            en  : in std_logic;
            clk : in std_logic;
            rst : in std_logic;

            sel : in std_logic_vector(2 downto 0); -- 0 ADD, 1 SUB, 2 MUL, 3 DIV, 4 INC, 5 DEC, 6 LSHIFT, 7 RSHIFT

            a : in std_logic_vector(7 downto 0);
            b : in std_logic_vector(7 downto 0);

            result : out std_logic_vector(7 downto 0);
            status : out std_logic_vector(1 downto 0) -- status(0) = nonzero, status(1) = positive
        );
    end component;

    component reg
        port (
            rw  : in std_logic;
            en  : in std_logic;
            clk : in std_logic;
            rst : in std_logic;

            address : in std_logic_vector(2 downto 0);

            address_a : in std_logic_vector(2 downto 0);
            address_b : in std_logic_vector(2 downto 0);

            data_in : in std_logic_vector(7 downto 0);

            data_out_a : out std_logic_vector(7 downto 0);
            data_out_b : out std_logic_vector(7 downto 0)
        );
    end component;

    component flipflop_rw

        port (
            en  : in std_logic;
            clk : in std_logic;
            rst : in std_logic;

            reg_rw_in  : in std_logic;
            ram_rw_in  : in std_logic;

            reg_rw_out : out std_logic;
            ram_rw_out : out std_logic
        );

    end component;

    component status
        port (
            en  : in std_logic;
            clk : in std_logic;
            rst : in std_logic;

            input  : in std_logic_vector(1 downto 0);
            output : out std_logic_vector(1 downto 0)
        );
    end component;

    component decoder
        port (
            en  : in std_logic;
            clk : in std_logic;

            instruction : in std_logic_vector(25 downto 0);
            reg_value_a : in std_logic_vector(7 downto 0);
            reg_value_b : in std_logic_vector(7 downto 0);
            ram_value   : in std_logic_vector(7 downto 0);
            status      : in std_logic_vector(1 downto 0);

            decoder_sw  : in std_logic_vector(7 downto 0);
            decoder_pc  : in std_logic_vector(7 downto 0);
            decoder_key : in std_logic;

            alu_sel : out std_logic_vector(2 downto 0);
            alu_a   : out std_logic_vector(7 downto 0);
            alu_b   : out std_logic_vector(7 downto 0);

            fetch_jump    : out std_logic;
            fetch_address : out std_logic_vector(7 downto 0);

            reg_rw        : out std_logic;
            reg_address   : out std_logic_vector(2 downto 0);
            reg_address_a : out std_logic_vector(2 downto 0);
            reg_address_b : out std_logic_vector(2 downto 0);

            ram_rw      : out std_logic;
            ram_address : out std_logic_vector(7 downto 0);
            ram_data_in : out std_logic_vector(7 downto 0);

            decoder_out_l : out std_logic_vector(7 downto 0);
            decoder_out_s : out std_logic_vector(7 downto 0)
        );
    end component;

    component pipeline
        port (
            clk : in std_logic;
            rst : in std_logic;

            stage : out std_logic_vector(7 downto 0)
        );
    end component;

    component screen
        port (
            data_a : in std_logic_vector(7 downto 0);
            data_b : in std_logic_vector(5 downto 0);

            HEX0 : out std_logic_vector(7 downto 0);
            HEX1 : out std_logic_vector(7 downto 0);
            HEX2 : out std_logic_vector(7 downto 0);
            HEX3 : out std_logic_vector(7 downto 0);
            HEX4 : out std_logic_vector(7 downto 0);
            HEX5 : out std_logic_vector(7 downto 0)
        );
    end component;

    signal general_clk : std_logic;
    signal general_rst : std_logic := '0';

    signal fetch_en          : std_logic;
    signal fetch_jump        : std_logic                    := '0';
    signal fetch_address_in  : std_logic_vector(7 downto 0) := "00000000";
    signal fetch_address_out : std_logic_vector(7 downto 0) := "00000000";

    signal rom_en      : std_logic;
    signal rom_address : std_logic_vector(7 downto 0)  := "00000000";
    signal rom_data    : std_logic_vector(25 downto 0) := "00000000000000000000000000";

    signal ram_rw       : std_logic := '0';
    signal ram_en       : std_logic;
    signal ram_address  : std_logic_vector(7 downto 0) := "00000000";
    signal ram_data_in  : std_logic_vector(7 downto 0) := "00000000";
    signal ram_data_out : std_logic_vector(7 downto 0) := "00000000";

    signal alu_en     : std_logic;
    signal alu_sel    : std_logic_vector(2 downto 0) := "000";
    signal alu_a      : std_logic_vector(7 downto 0) := "00000000";
    signal alu_b      : std_logic_vector(7 downto 0) := "00000000";
    signal alu_result : std_logic_vector(7 downto 0) := "00000000";
    signal alu_status : std_logic_vector(1 downto 0) := "00";

    signal reg_rw         : std_logic := '0';
    signal reg_en         : std_logic;
    signal reg_address    : std_logic_vector(2 downto 0) := "000";
    signal reg_address_a  : std_logic_vector(2 downto 0) := "000";
    signal reg_address_b  : std_logic_vector(2 downto 0) := "000";
    signal reg_data_in    : std_logic_vector(7 downto 0) := "00000000";
    signal reg_data_out_a : std_logic_vector(7 downto 0) := "00000000";
    signal reg_data_out_b : std_logic_vector(7 downto 0) := "00000000";

    signal status_en     : std_logic;
    signal status_input  : std_logic_vector(1 downto 0) := "00";
    signal status_output : std_logic_vector(1 downto 0) := "00";

    signal decoder_en : std_logic;

    signal pipeline_stage : std_logic_vector(7 downto 0) := "00000000";
    signal decoder_out_l    : std_logic_vector(7 downto 0) := "00000000";
    signal decoder_out_s    : std_logic_vector(7 downto 0) := "00000000";

    signal decoder_reg_rw : std_logic := '0';
    signal decoder_ram_rw : std_logic := '0';

begin
    -- Program Counter Instantiation
    pcounter_inst : pcounter
    port map(
        en          => fetch_en,
        clk         => general_clk,
        rst         => general_rst,
        jump        => fetch_jump,
        address_in  => fetch_address_in,
        address_out => fetch_address_out
    );

    -- ROM Instantiation
    rom_inst : rom
    port map(
        en      => rom_en,
        clk     => general_clk,
        rst     => general_rst,
        address => rom_address,
        data    => rom_data
    );

    -- RAM Instantiation
    ram_inst : ram
    port map(
        rw       => ram_rw,
        en       => ram_en,
        clk      => general_clk,
        rst      => general_rst,
        address  => ram_address,
        data_in  => ram_data_in,
        data_out => ram_data_out
    );

    -- ALU Instantiation
    alu_inst : alu
    port map(
        en     => alu_en,
        clk    => general_clk,
        rst    => general_rst,
        sel    => alu_sel,
        a      => alu_a,
        b      => alu_b,
        result => alu_result,
        status => alu_status
    );

    -- REG Instantiation
    reg_inst : reg
    port map(
        rw         => reg_rw,
        en         => reg_en,
        clk        => general_clk,
        rst        => general_rst,
        address    => reg_address,
        address_a  => reg_address_a,
        address_b  => reg_address_b,
        data_in    => reg_data_in,
        data_out_a => reg_data_out_a,
        data_out_b => reg_data_out_b
    );

    -- Status Instantiation
    status_inst : status
    port map(
        en     => status_en,
        clk    => general_clk,
        rst    => general_rst,
        input  => status_input,
        output => status_output
    );

    rom_address  <= fetch_address_out;
    status_input <= alu_status;
    reg_data_in  <= alu_result;
    general_clk  <= MAX10_CLK1_50;
    general_rst  <= not KEY(1);

    -- Flip Flop Instantiation
    flipflop_rw_inst : flipflop_rw
    port map(
        en         => alu_en,
        clk        => general_clk,
        rst        => general_rst,
        reg_rw_in  => decoder_reg_rw,
        ram_rw_in  => decoder_ram_rw,

        reg_rw_out => reg_rw,
        ram_rw_out => ram_rw
    );

    -- Decoder Instantiation
    decoder_inst : decoder
    port map(
        en  => decoder_en,
        clk => general_clk,

        instruction => rom_data,
        reg_value_a => reg_data_out_a,
        reg_value_b => reg_data_out_b,
        ram_value   => ram_data_out,
        status      => status_output,

        decoder_pc => rom_address,
        decoder_sw  => SW(7 downto 0),
        decoder_key => KEY(0),

        alu_sel => alu_sel,
        alu_a   => alu_a,
        alu_b   => alu_b,

        fetch_jump    => fetch_jump,
        fetch_address => fetch_address_in,

        reg_rw        => decoder_reg_rw,
        reg_address   => reg_address,
        reg_address_a => reg_address_a,
        reg_address_b => reg_address_b,

        ram_rw      => decoder_ram_rw,
        ram_address => ram_address,
        ram_data_in => ram_data_in,

        decoder_out_l => decoder_out_l,
        decoder_out_s => decoder_out_s
    );

    -- Pipeline Instantation
    -- Static pipeline, no matter what is the instruction:
    -- Fetch => ROM => Decoder => RAM + REG => Decoder => ALU => RAM + REG + STATUS => ...
    pipeline_inst : pipeline
    port map(
        clk   => general_clk,
        rst   => general_rst,
        stage => pipeline_stage
    );

    fetch_en   <= pipeline_stage(0);
    rom_en     <= pipeline_stage(1);
    decoder_en <= pipeline_stage(2);
    reg_en     <= pipeline_stage(3);
    ram_en     <= pipeline_stage(4);
    alu_en     <= pipeline_stage(5);
    status_en  <= pipeline_stage(6);

    --ram_rw <= pipeline_stage(7) and decoder_ram_rw;
    --reg_rw <= pipeline_stage(7) and decoder_reg_rw;

    -- Screen
    screen_inst : screen
    port map(
        data_a => decoder_out_l,
        data_b => decoder_out_s(5 downto 0),

        HEX0 => HEX0,
        HEX1 => HEX1,
        HEX2 => HEX2,
        HEX3 => HEX3,
        HEX4 => HEX4,
        HEX5 => HEX5
    );

    LEDR(7 downto 0) <= SW(7 downto 0);
    LEDR(9 downto 8) <= "00";

end architecture;
