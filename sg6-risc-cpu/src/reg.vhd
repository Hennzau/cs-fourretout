library ieee;

use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity reg is
    port (
        rw : in std_logic;

        en  : in std_logic;
        clk : in std_logic;
        rst : in std_logic;

        address : in std_logic_vector(2 downto 0);

        address_a : in std_logic_vector(2 downto 0);
        address_b : in std_logic_vector(2 downto 0);

        data_in : in std_logic_vector(7 downto 0);

        data_out_a : out std_logic_vector(7 downto 0) := "00000000";
        data_out_b : out std_logic_vector(7 downto 0) := "00000000"
    );
end reg;

architecture Behavioral of reg is

    type reg is array(0 to 7) of std_logic_vector(7 downto 0);

    signal data_reg : reg;

begin
    WRITE: process (rst, clk)
    begin
        if rst = '1' then
            for k in 0 to 7 loop
                data_reg(k) <= (others => '0');
            end loop;
        else
            if rising_edge(clk) then
                if en = '1' then
                    if rw = '1' then
                        data_reg(to_integer(unsigned(address))) <= data_in;
                    --else
                    --    data_out_a <= data_reg(to_integer(unsigned(address_a)));
                    --    data_out_b <= data_reg(to_integer(unsigned(address_b)));
                    end if;
                end if;
            end if;
        end if;

    end process;

    READ: process (data_reg, address_a, address_b)
    begin
        data_out_a <= data_reg(to_integer(unsigned(address_a)));
        data_out_b <= data_reg(to_integer(unsigned(address_b)));
    end process;

end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_tb is
end reg_tb;

architecture Behavioral of reg_tb is

    -- Constants
    constant clk_period : time := 10 ns;

    -- Signals
    signal rw        : std_logic;
    signal en        : std_logic;
    signal clk       : std_logic := '0';
    signal rst       : std_logic;
    signal address   : std_logic_vector(2 downto 0);
    signal address_a : std_logic_vector(2 downto 0);
    signal address_b : std_logic_vector(2 downto 0);
    signal data_in   : std_logic_vector(7 downto 0);
    signal data_out_a: std_logic_vector(7 downto 0);
    signal data_out_b: std_logic_vector(7 downto 0);

begin

    -- Clock generation
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- DUT instantiation
    uut: entity work.reg
        port map (
            rw         => rw,
            en         => en,
            clk        => clk,
            rst        => rst,
            address    => address,
            address_a  => address_a,
            address_b  => address_b,
            data_in    => data_in,
            data_out_a => data_out_a,
            data_out_b => data_out_b
        );

    -- Test process
    test_process : process
    begin
        -- Test 1: Reset all registers
        rst <= '1';
        en <= '0';
        rw <= '0';
        wait for clk_period;
        rst <= '0';
        wait for clk_period;

        -- Test 2: Write data to register 0
        en <= '1';
        rw <= '1';
        address <= "000"; -- Register 0
        data_in <= "10101010"; -- Write 0xAA
        wait for clk_period;

        -- Test 3: Write data to register 1
        address <= "001"; -- Register 1
        data_in <= "01010101"; -- Write 0x55
        wait for clk_period;

        -- Test 4: Read data from register 0 and register 1
        rw <= '0';
        address_a <= "000"; -- Read register 0
        address_b <= "001"; -- Read register 1
        wait for clk_period;

        -- Test 5: Write and read simultaneously
        rw <= '1';
        address <= "010"; -- Write to register 2
        data_in <= "11110000"; -- Write 0xF0
        wait for clk_period;
        rw <= '0';
        address_a <= "010"; -- Read register 2
        address_b <= "000"; -- Read register 0
        wait for clk_period;

        -- End of test
        wait;
    end process;

end Behavioral;
