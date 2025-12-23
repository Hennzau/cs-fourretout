library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dig2dec is
    port (
        data_a : in std_logic_vector(7 downto 0);
        data_b : in std_logic_vector(5 downto 0);

        seg0 : out std_logic_vector(3 downto 0) := "0000";
        seg1 : out std_logic_vector(3 downto 0) := "0000";
        seg2 : out std_logic_vector(3 downto 0) := "0000";
        seg3 : out std_logic_vector(3 downto 0) := "0000";
        seg4 : out std_logic_vector(3 downto 0) := "0000";
        seg5 : out std_logic_vector(3 downto 0) := "0000"
    );
end entity;

architecture Behavioral of dig2dec is

begin
    process (data_a, data_b)
        variable b1 : unsigned(5 downto 0); -- La valeur initiale (6 bits)
        variable b4 : unsigned(3 downto 0); -- E(data_b/10) : les dizaines (4 bits)
        variable b3 : unsigned(3 downto 0); -- data_b - b4*10 : les unités (4 bits)

        variable a_abs : unsigned(7 downto 0); -- Valeur absolue de data_a (8 bits)
        variable a3    : unsigned(3 downto 0); -- Les centaines (4 bits)
        variable a2    : unsigned(3 downto 0); -- Les dizaines (4 bits)
        variable a1    : unsigned(3 downto 0); -- Les unités (4 bits)

        variable minus : integer := 3;
    begin
        b1 := unsigned(data_b);

        b4 := resize(b1 / 10, b4'length);      -- Les dizaines
        b3 := resize(b1 - b4 * 10, b3'length); -- Les unités

        if b1 >= 10 then
            seg5 <= std_logic_vector(b4); -- Les dizaines
        else
            seg5 <= X"B";
        end if;

        seg4 <= std_logic_vector(b3); -- Les unités

        a_abs := unsigned(abs(signed(data_a)));
        a3    := resize(a_abs / 100, a3'length);
        a2    := resize((a_abs / 10) mod 10, a2'length);
        a1    := resize(a_abs mod 10, a1'length);

        minus := 3;

        if a_abs >= 100 then
            seg2 <= std_logic_vector(a3);
        else
            seg2 <= X"B";
            minus := 2;
        end if;

        if a_abs >= 10 then
            seg1 <= std_logic_vector(a2);
        else
            seg1 <= X"B";
            minus := 1;
        end if;

        seg0 <= std_logic_vector(a1);
        seg3 <= X"B";

        if signed(data_a) < 0 then
            if minus = 3 then
                seg3 <= X"a";
            elsif minus = 2 then
                seg2 <= X"a";
            elsif minus = 1 then
                seg1 <= X"a";
            end if;
        end if;

    end process;

end architecture;
