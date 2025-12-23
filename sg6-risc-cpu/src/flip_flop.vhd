library ieee;

use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity flipflop_rw is

    port (
        en  : in std_logic;
        clk : in std_logic;
        rst : in std_logic;

        reg_rw_in  : in std_logic;
        ram_rw_in  : in std_logic;

        reg_rw_out : out std_logic;
        ram_rw_out : out std_logic
    );

end flipflop_rw;

architecture Behavioral of flipflop_rw is

begin
    process (rst, clk)
    begin
        if rst = '1' then
            reg_rw_out <= '0';
            ram_rw_out <= '0';
        else
            if rising_edge(clk) then
                if en = '1' then
                    reg_rw_out <= reg_rw_in;
                    ram_rw_out <= ram_rw_in;
                end if;
            end if;
        end if;
    end process;

end architecture;
