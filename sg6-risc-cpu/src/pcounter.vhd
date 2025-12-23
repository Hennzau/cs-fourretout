library ieee;

use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity pcounter is
    port (
        en  : in std_logic;
        clk : in std_logic;
        rst : in std_logic := '0';

        jump : in std_logic := '0';

        address_in  : in std_logic_vector(7 downto 0);

        address_out : out std_logic_vector(7 downto 0) := "00000000"
    );
end entity;

architecture Behavioral of pcounter is

    signal address : std_logic_vector(7 downto 0) := "00000000";

begin
    process (rst, clk)
    begin
        if rst = '1' then
            address <= (others => '0');
        else
            if rising_edge(clk) then
                if en = '1' then
                    if jump = '0' then
                        address <= std_logic_vector(unsigned(address) + 1);
                    else
                        address <= address_in;
                    end if;
                end if;
            end if;
        end if;
    end process;

    address_out <= address;

end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pcounter_tb is
end entity;

architecture Behavioral of pcounter_tb is

    -- Constants
    constant clk_period : time := 10 ns;

    -- Signals
    signal en          : std_logic;
    signal clk         : std_logic := '0';
    signal rst         : std_logic;
    signal jump        : std_logic;
    signal address_in  : std_logic_vector(7 downto 0);
    signal address_out : std_logic_vector(7 downto 0);

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
    uut: entity work.pcounter
        port map (
            en          => en,
            clk         => clk,
            rst         => rst,
            jump        => jump,
            address_in  => address_in,
            address_out => address_out
        );

    -- Test process
    test_process : process
    begin
        -- Test 1: Reset
        rst <= '1';
        en <= '0';
        jump <= '0';
        address_in <= (others => '0');
        wait for clk_period;
        rst <= '0';
        wait for clk_period;

        -- Test 2: Increment address
        en <= '1';
        jump <= '0';
        wait for clk_period;
        wait for clk_period;

        -- Test 3: Jump to specific address
        jump <= '1';
        address_in <= "10101010"; -- Jump to 0xAA
        wait for clk_period;

        -- Test 4: Resume incrementing
        jump <= '0';
        wait for clk_period;
        wait for clk_period;

        -- Test 5: Disable counter
        en <= '0';
        wait for clk_period;
        wait for clk_period;

        -- End of test
        wait;
    end process;

end Behavioral;
