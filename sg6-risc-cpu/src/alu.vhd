library ieee;

use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity alu is
    port (
        en  : in std_logic;
        clk : in std_logic;
        rst : in std_logic;

        sel : in std_logic_vector(2 downto 0); -- 0 ADD, 1 SUB, 2 MUL, 3 DIV, 4 INC, 5 DEC, 6 LSHIFT, 7 RSHIFT

        a : in std_logic_vector(7 downto 0);
        b : in std_logic_vector(7 downto 0);

        result : out std_logic_vector(7 downto 0) := "00000000";
        status : out std_logic_vector(1 downto 0) := "00" -- status(0) = nonzero, status(1) = positive
    );
end entity;

architecture Behavioral of alu is

begin
    process (rst, clk)
        variable a_signed    : signed(7 downto 0)  := "00000000";
        variable b_signed    : signed(7 downto 0)  := "00000000";
        variable temp_result : signed(15 downto 0) := "0000000000000000";
    begin
        if rst = '1' then
            result <= (others => '0');
            status <= (others => '0');
        elsif rising_edge(clk) then
            if en = '1' then
                a_signed := signed(a);
                b_signed := signed(b);

                temp_result := to_signed(0, 16);

                case sel is
                    when "000" => -- ADD
                        temp_result(7 downto 0) := a_signed + b_signed;

                    when "001" => -- SUB
                        temp_result(7 downto 0) := a_signed - b_signed;

                    when "010" => -- MUL
                        temp_result(7 downto 0) := to_signed(to_integer(a_signed * b_signed), 8);

                    when "011" => -- DIV
                        temp_result(7 downto 0) := a_signed / b_signed;

                    when "100" => -- INC
                        if a_signed = 127 then
                            temp_result(7 downto 0) := to_signed(127, 8);
                        else
                            temp_result(7 downto 0) := a_signed + 1;
                        end if;

                    when "101" => -- DEC
                        if a_signed =- 128 then
                            temp_result(7 downto 0) := to_signed(-128, 8);
                        else
                            temp_result(7 downto 0) := a_signed - 1;
                        end if;

                    when "110" => -- LSHIFT (Logical Shift Left)
                        temp_result(7 downto 0) := shift_left(a_signed, 1);

                    when "111" => -- RSHIFT (Logical Shift Right)
                        temp_result(7 downto 0) := shift_right(a_signed, 1);

                    when others       =>
                        temp_result(7 downto 0) := "00000000";
                end case;

                result <= std_logic_vector(temp_result(7 downto 0));

                -- Set status bits
                if temp_result(7 downto 0) /= 0 then
                    status(0) <= '1'; -- nonzero
                else
                    status(0) <= '0';
                end if;

                if temp_result(7 downto 0) >= 0 then
                    status(1) <= '1'; -- positive
                else
                    status(1) <= '0';
                end if;
            end if;
        end if;
    end process;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_tb is
end entity;

architecture Behavioral of alu_tb is

    -- Constants
    constant clk_period : time := 10 ns;

    -- Signals
    signal en      : std_logic;
    signal clk     : std_logic := '0';
    signal rst     : std_logic;
    signal sel     : std_logic_vector(2 downto 0);
    signal a       : std_logic_vector(7 downto 0);
    signal b       : std_logic_vector(7 downto 0);
    signal result  : std_logic_vector(7 downto 0);
    signal status  : std_logic_vector(1 downto 0);

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
    uut: entity work.alu
        port map (
            en      => en,
            clk     => clk,
            rst     => rst,
            sel     => sel,
            a       => a,
            b       => b,
            result  => result,
            status  => status
        );

    -- Test process
    test_process : process
    begin
        -- Test 1: Reset
        rst <= '1';
        en <= '0';
        sel <= "000";
        a <= (others => '0');
        b <= (others => '0');
        wait for clk_period;
        rst <= '0';
        wait for clk_period;

        -- Test 2: Addition
        en <= '1';
        sel <= "000"; -- ADD
        a <= "00001010"; -- 10
        b <= "00000101"; -- 5
        wait for clk_period;

        -- Test 3: Subtraction
        sel <= "001"; -- SUB
        a <= "00001010"; -- 10
        b <= "00000101"; -- 5
        wait for clk_period;

        -- Test 4: Multiplication
        sel <= "010"; -- MUL
        a <= "00000011"; -- 3
        b <= "00000010"; -- 2
        wait for clk_period;

        -- Test 5: Division
        sel <= "011"; -- DIV
        a <= "00001010"; -- 10
        b <= "00000010"; -- 2
        wait for clk_period;

        -- Test 6: Increment
        sel <= "100"; -- INC
        a <= "00000101"; -- 5
        wait for clk_period;

        -- Test 7: Decrement
        sel <= "101"; -- DEC
        a <= "00000101"; -- 5
        wait for clk_period;

        -- Test 8: Logical Shift Left
        sel <= "110"; -- LSHIFT
        a <= "00000010"; -- 2
        wait for clk_period;

        -- Test 9: Logical Shift Right
        sel <= "111"; -- RSHIFT
        a <= "00000100"; -- 4
        wait for clk_period;

        -- End of test
        wait;
    end process;

end Behavioral;
