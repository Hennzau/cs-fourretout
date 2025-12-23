library ieee;

use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity status is

    port (
        en  : in std_logic;
        clk : in std_logic;
        rst : in std_logic;

        input  : in std_logic_vector(1 downto 0);
        output : out std_logic_vector(1 downto 0) := "00"
    );

end status;

architecture status_a of status is

begin
    acces_status : process (rst, clk)
    begin
        if rst = '1' then
            output <= (others => '0');
        else
            if rising_edge(clk) then
                if en = '1' then
                    output <= input;
                end if;
            end if;
        end if;

    end process acces_status;

end status_a;
