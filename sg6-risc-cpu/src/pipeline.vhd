library ieee;

use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity pipeline is

    port (
        rst : in std_logic;
        clk : in std_logic;

        -- 0 is fetch
        -- 1 is rom
        -- 2 is decoder
        -- 3 is reg
        -- 4 is ram
        -- 5 is alu
        -- 6 is status
        -- 7 is for read/write mode
        stage : out std_logic_vector(7 downto 0) := "00000000" -- everything disabled
    );

end entity;

architecture pipeline_a of pipeline is

begin
    pipeline : process (clk, rst)
        variable counter : unsigned(3 downto 0) := to_unsigned(1, 4);
    begin
        if rst = '1' then
            counter := to_unsigned(1, 4);
        else
            if rising_edge(clk) then
                case counter is
                    when to_unsigned(0, 4) =>
                        stage <= "00000001"; -- fetch
                        counter := counter + 1;
                    when to_unsigned(1, 4) =>
                        stage <= "00000010"; -- rom
                        counter := counter + 1;
                    when to_unsigned(2, 4) =>
                        stage <= "00000100"; -- decoder
                        counter := counter + 1;
                    --when to_unsigned(3, 4) =>
                    --    stage <= "00011000"; -- ram + reg (possible read)
                    --    counter := counter + 1;
                    --when to_unsigned(4, 4) =>
                    --    stage <= "00000100"; -- decoder again (load memory values into decoder)
                    --    counter := counter + 1;
                    when to_unsigned(3, 4) =>
                        stage <= "00100000"; -- alu
                        counter := counter + 1;
                    when to_unsigned(4, 4) =>
                        stage <= "11011000"; -- ram + reg + status (possible write)
                        counter := to_unsigned(0, 4);

                        -- Note : meme en cas de jump sur le status, c'est bon car après une
                        -- updatede status non souhaitée, la valeur qui est au branchement du
                        -- fetch n'a pas encore été mise à our et donc c'est bien la bonne

                    when others => -- IMPOSIBLE CASE
                        counter := to_unsigned(0, 4);
                end case;
            end if;
        end if;
    end process;

end architecture;
