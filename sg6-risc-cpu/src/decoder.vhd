library ieee;

use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity decoder is

    port (
        en  : in std_logic;
        clk : in std_logic;

        instruction : in std_logic_vector(25 downto 0);
        reg_value_a : in std_logic_vector(7 downto 0);
        reg_value_b : in std_logic_vector(7 downto 0);
        ram_value   : in std_logic_vector(7 downto 0);
        status      : in std_logic_vector(1 downto 0);

        decoder_pc  : in std_logic_vector(7 downto 0);
        decoder_sw  : in std_logic_vector(7 downto 0);
        decoder_key : in std_logic;

        alu_sel : out std_logic_vector(2 downto 0) := "000";
        alu_a   : out std_logic_vector(7 downto 0) := "00000000";
        alu_b   : out std_logic_vector(7 downto 0) := "00000000";

        fetch_jump    : out std_logic                    := '0';
        fetch_address : out std_logic_vector(7 downto 0) := "00000000";

        reg_rw        : out std_logic                    := '0';
        reg_address   : out std_logic_vector(2 downto 0) := "000";
        reg_address_a : out std_logic_vector(2 downto 0) := "000";
        reg_address_b : out std_logic_vector(2 downto 0) := "000";

        ram_rw      : out std_logic                    := '0';
        ram_address : out std_logic_vector(7 downto 0) := "00000000";
        ram_data_in : out std_logic_vector(7 downto 0) := "00000000";

        decoder_out_l : out std_logic_vector(7 downto 0) := "00000000";
        decoder_out_s : out std_logic_vector(7 downto 0) := "00000000"
    );

end entity;

architecture Behavioral of decoder is

begin
    decode : process (en, instruction, reg_value_a, reg_value_b, ram_value, status, decoder_pc, decoder_sw, decoder_key)

        variable alu_op : std_logic_vector(2 downto 0);

        variable format : std_logic_vector(1 downto 0);
        variable op     : std_logic_vector(4 downto 0);
        variable reg    : std_logic_vector(2 downto 0);
        variable A      : std_logic_vector(7 downto 0);
        variable B      : std_logic_vector(7 downto 0);

    begin
        --if rising_edge(clk) then
        --    dec_instruction := instruction;
        --else
        if en = '1' then
            format := instruction(25 downto 24);
            op     := instruction(23 downto 19);
            reg    := instruction(18 downto 16);
            A      := instruction(15 downto 8);
            B      := instruction(7 downto 0);

            if op(4) = '0' and op(3) = '0' then -- ALU operation
                alu_op := op(2 downto 0);

                reg_rw <= '1'; -- always write on reg when ALU operation
                ram_rw <= '0';

                reg_address   <= reg;
                reg_address_a <= A(2 downto 0);
                reg_address_b <= B(2 downto 0);

                alu_sel <= alu_op;

                case format is
                    when "00" =>
                        alu_a <= reg_value_a;
                        alu_b <= reg_value_b;
                    when "01" =>
                        alu_a <= A;
                        alu_b <= B;
                    when "10" =>
                        alu_a <= reg_value_a;
                        alu_b <= B;
                    when others =>
                        null;
                end case;
            else -- Not an ALU OP
                reg_address_a <= A(2 downto 0);
                alu_b         <= (others => '0');
                alu_sel       <= "000";
                reg_address   <= reg;

                reg_rw     <= '0';
                ram_rw     <= '0';
                fetch_jump <= '0';

                case op is
                    when "10010" => -- NOP
                        reg_rw <= '0';
                        ram_rw <= '0';

                    when "10011" => -- PRINT
                        reg_rw <= '0';
                        ram_rw <= '0';

                        case format is
                            when "00" => -- ALL REG
                                decoder_out_l <= reg_value_a;
                            when "01" => -- ALL IMM
                                decoder_out_l <= A;
                            when "10" => -- Duplicated from 00
                                decoder_out_l <= reg_value_a;
                            when others =>
                                null;
                        end case;
                    when "01011" => -- SPRINT (small print)
                        reg_rw <= '0';
                        ram_rw <= '0';

                        case format is
                            when "00" => -- ALL REG
                                decoder_out_s <= reg_value_a;
                            when "01" => -- ALL IMM
                                decoder_out_s <= A;
                            when "10" => -- Duplicated from 00
                                decoder_out_s <= reg_value_a;
                            when others =>
                                null;
                        end case;
                    when "01000" => -- LOAD PC
                        reg_rw <= '1';
                        ram_rw <= '0';

                        alu_a <= decoder_pc;

                    when "01001" => -- LOAD SW
                        reg_rw <= '1';
                        ram_rw <= '0';

                        alu_a <= decoder_sw;
                    when "01010" => -- LOAD KEY
                        reg_rw <= '1';
                        ram_rw <= '0';

                        alu_a(7 downto 1) <= "0000000";
                        alu_a(0) <= decoder_key;
                    when "10001" => -- MOV
                        reg_rw <= '1';
                        ram_rw <= '0';

                        case format is
                            when "00" => -- ALL REG
                                alu_a <= reg_value_a;
                            when "01" =>
                                alu_a <= A;
                            when "10" => -- Duplicated from 00
                                alu_a <= reg_value_a;
                            when others =>
                                null;
                        end case;
                    when "10100" => -- REG2RAM
                        ram_rw <= '1';
                        reg_rw <= '0';

                        ram_address   <= A;
                        ram_data_in   <= reg_value_a;
                        reg_address_a <= reg;
                    when "10101" => -- RAM2REG
                        ram_rw <= '0';
                        reg_rw <= '1';

                        ram_address <= A;

                        alu_a <= ram_value;
                    when "01100" => -- JUMP
                        ram_rw <= '0';
                        reg_rw <= '0';

                        case format is
                            when "00" =>
                                fetch_jump    <= '1';
                                fetch_address <= reg_value_a;
                            when "01" =>
                                fetch_jump    <= '1';
                                fetch_address <= A;
                            when "10" =>
                                fetch_jump    <= '1';
                                fetch_address <= reg_value_a;
                            when others =>
                                null;
                        end case;
                    when "01101" => -- ZJMP
                        ram_rw <= '0';
                        reg_rw <= '0';

                        if status(0) = '0' then
                            case format is
                                when "00" =>
                                    fetch_jump    <= '1';
                                    fetch_address <= reg_value_a;
                                when "01" =>
                                    fetch_jump    <= '1';
                                    fetch_address <= A;
                                when "10" =>
                                    fetch_jump    <= '1';
                                    fetch_address <= reg_value_a;
                                when others =>
                                    null;
                            end case;
                        end if;
                    when "01110" => -- NZJMP
                        ram_rw <= '0';
                        reg_rw <= '0';

                        if status(0) = '1' then
                            case format is
                                when "00" =>
                                    fetch_jump    <= '1';
                                    fetch_address <= reg_value_a;
                                when "01" =>
                                    fetch_jump    <= '1';
                                    fetch_address <= A;
                                when "10" =>
                                    fetch_jump    <= '1';
                                    fetch_address <= reg_value_a;
                                when others =>
                                    null;
                            end case;
                        end if;
                    when "01111" => -- PJMP
                        ram_rw <= '0';
                        reg_rw <= '0';
                        if status(1) = '1' then
                            case format is
                                when "00" =>
                                    fetch_jump    <= '1';
                                    fetch_address <= reg_value_a;
                                when "01" =>
                                    fetch_jump    <= '1';
                                    fetch_address <= A;
                                when "10" =>
                                    fetch_jump    <= '1';
                                    fetch_address <= reg_value_a;
                                when others =>
                                    null;
                            end case;
                        end if;
                    when "10000" => -- NPJMP
                        ram_rw <= '0';
                        reg_rw <= '0';
                        if status(1) = '0' then
                            case format is
                                when "00" =>
                                    fetch_jump    <= '1';
                                    fetch_address <= reg_value_a;
                                when "01" =>
                                    fetch_jump    <= '1';
                                    fetch_address <= A;
                                when "10" =>
                                    fetch_jump    <= '1';
                                    fetch_address <= reg_value_a;
                                when others =>
                                    null;
                            end case;
                        end if;
                    when others =>
                        null;
                end case;
            end if;
        end if;
        --end if;
    end process;

end architecture;

library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.ALL;

entity decoder_tb is
end decoder_tb;

architecture Behavioral of decoder_tb is

    -- Signals for decoder inputs
    signal en            : std_logic := '0';
    signal clk           : std_logic := '0';
    signal instruction   : std_logic_vector(25 downto 0) := (others => '0');
    signal reg_value_a   : std_logic_vector(7 downto 0) := (others => '0');
    signal reg_value_b   : std_logic_vector(7 downto 0) := (others => '0');
    signal ram_value     : std_logic_vector(7 downto 0) := (others => '0');
    signal status        : std_logic_vector(1 downto 0) := (others => '0');
    signal decoder_pc    : std_logic_vector(7 downto 0) := (others => '0');
    signal decoder_sw    : std_logic_vector(7 downto 0) := (others => '0');
    signal decoder_key   : std_logic := '0';

    -- Signals for decoder outputs
    signal alu_sel       : std_logic_vector(2 downto 0);
    signal alu_a         : std_logic_vector(7 downto 0);
    signal alu_b         : std_logic_vector(7 downto 0);
    signal fetch_jump    : std_logic;
    signal fetch_address : std_logic_vector(7 downto 0);
    signal reg_rw        : std_logic;
    signal reg_address   : std_logic_vector(2 downto 0);
    signal reg_address_a : std_logic_vector(2 downto 0);
    signal reg_address_b : std_logic_vector(2 downto 0);
    signal ram_rw        : std_logic;
    signal ram_address   : std_logic_vector(7 downto 0);
    signal ram_data_in   : std_logic_vector(7 downto 0);
    signal decoder_out_l : std_logic_vector(7 downto 0);
    signal decoder_out_s : std_logic_vector(7 downto 0);

    -- Clock period
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the decoder
    uut: entity work.decoder
        port map (
            en             => en,
            clk            => clk,
            instruction    => instruction,
            reg_value_a    => reg_value_a,
            reg_value_b    => reg_value_b,
            ram_value      => ram_value,
            status         => status,
            decoder_pc     => decoder_pc,
            decoder_sw     => decoder_sw,
            decoder_key    => decoder_key,
            alu_sel        => alu_sel,
            alu_a          => alu_a,
            alu_b          => alu_b,
            fetch_jump     => fetch_jump,
            fetch_address  => fetch_address,
            reg_rw         => reg_rw,
            reg_address    => reg_address,
            reg_address_a  => reg_address_a,
            reg_address_b  => reg_address_b,
            ram_rw         => ram_rw,
            ram_address    => ram_address,
            ram_data_in    => ram_data_in,
            decoder_out_l  => decoder_out_l,
            decoder_out_s  => decoder_out_s
        );

    -- Clock generation process
    clk_process: process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Test stimulus process
    stimulus_process: process
    begin
        -- Test 1: ADD between two registers R0 and R1 put in R3
        en <= '1';
        instruction <= "00" & "00000" & "010" & "00000000" & "00000001";
        wait for 10 ns;

        -- Test 2: ADD between registers with reg_values for ALU A and B
        instruction <= "00" & "00000" & "010" & "00000000" & "00000001";
        reg_value_a <= "00001111"; -- Value in R0
        reg_value_b <= "11110000"; -- Value in R1
        wait for 10 ns;

        -- Test 3: JUMP to addr 28
        instruction <= "01" & "01100" & "000" & "00011100" & "00000000";
        wait for 10 ns;

        wait;
    end process;

end Behavioral;
