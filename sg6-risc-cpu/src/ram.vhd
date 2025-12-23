library ieee;

use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity ram is
    port (
        rw : in std_logic := '0';

        en  : in std_logic;
        clk : in std_logic;
        rst : in std_logic;

        address : in std_logic_vector(7 downto 0);
        data_in  : in std_logic_vector(7 downto 0);

        data_out : out std_logic_vector(7 downto 0) := "00000000"
    );
end ram;

architecture Behavioral of ram is

    type ram is array(0 to 255) of std_logic_vector(7 downto 0);

    signal data_ram : ram;

begin
    WRITE: process (rst, clk)
    begin
        if rst /= '1' then
            if rising_edge(clk) then
                if en = '1' then
                    if rw = '1' then
                        data_ram(to_integer(unsigned(address))) <= data_in;
                    --else
                    --    data_out <= data_ram(to_integer(unsigned(address)));
                    end if;
                end if;
            end if;
        end if;

    end process;

    READ: process (data_ram, address)
    begin
        data_out <= data_ram(to_integer(unsigned(address)));
    end process;

end architecture;
