library ieee;

use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity rom is

    port (
        en  : in std_logic;
        clk : in std_logic;
        rst : in std_logic;

        address : in std_logic_vector(7 downto 0);

        data : out std_logic_vector(25 downto 0) := "00000000000000000000000000"
    );

end rom;

architecture Behavioral of rom is

    type alu_op_type is (ADD, SUB, MUL, DIV, RSHIFT, LSHIFT, INC, DEC);

    type alu_op_table is array (alu_op_type) of std_logic_vector(4 downto 0);
    constant ALU : alu_op_table := (
        ADD => "00000",
        SUB => "00001",
        MUL => "00010",
        DIV => "00011",

        INC => "00100",
        DEC => "00101",

        LSHIFT => "00110",
        RSHIFT => "00111"
    );

    type format_type is (REG, IMM, BOTH);

    type format_table is array (format_type) of std_logic_vector(1 downto 0);
    constant FORMAT : format_table := (
        REG  => "00",
        IMM  => "01",
        BOTH => "10"
    );

    constant MOV   : std_logic_vector(4 downto 0) := "10001";
    constant PRINT : std_logic_vector(7 downto 0) := "10011" & "000";
    constant SPRINT : std_logic_vector(7 downto 0) := "01011" & "000";

    type ram_type is (FROM_REG, TO_REG);

    type ram_table is array (ram_type) of std_logic_vector(6 downto 0);
    constant RAM : ram_table := (
        FROM_REG => "00" & "10100",
        TO_REG   => "00" & "10101"
    );

    type jump_type is (ADDR, Z, NZ, P, NP);

    type jump_table is array (jump_type) of std_logic_vector(7 downto 0);
    constant JUMP : jump_table := (
        ADDR => "01100" & "000",
        Z    => "01101" & "000",
        NZ   => "01110" & "000",
        P    => "01111" & "000",
        NP   => "10000" & "000"
    );

    constant R0 : std_logic_vector(2 downto 0) := "000";
    constant R1 : std_logic_vector(2 downto 0) := "001";
    constant R2 : std_logic_vector(2 downto 0) := "010";
    constant R3 : std_logic_vector(2 downto 0) := "011";
    constant R4 : std_logic_vector(2 downto 0) := "100";
    constant R5 : std_logic_vector(2 downto 0) := "101";
    constant R6 : std_logic_vector(2 downto 0) := "110";
    constant R7 : std_logic_vector(2 downto 0) := "111";

    constant R0_8 : std_logic_vector(7 downto 0) := "00000000";
    constant R1_8 : std_logic_vector(7 downto 0) := "00000001";
    constant R2_8 : std_logic_vector(7 downto 0) := "00000010";
    constant R3_8 : std_logic_vector(7 downto 0) := "00000011";
    constant R4_8 : std_logic_vector(7 downto 0) := "00000100";
    constant R5_8 : std_logic_vector(7 downto 0) := "00000101";
    constant R6_8 : std_logic_vector(7 downto 0) := "00000110";
    constant R7_8 : std_logic_vector(7 downto 0) := "00000111";

    constant NOP    : std_logic_vector(25 downto 0) := "00" & "10010" & "000" & "00000000" & "00000000";
    constant IGNORE : std_logic_vector(7 downto 0)  := "00000000";

    constant LOAD_PC : std_logic_vector(6 downto 0) := "00" & "01000";
    constant LOAD_SW : std_logic_vector(6 downto 0) := "00" & "01001";
    constant LOAD_KEY : std_logic_vector(6 downto 0) := "00" & "01010";

    function imm(value : integer) return std_logic_vector is
    begin
        return std_logic_vector(to_signed(value, 8));
    end function;

    function addr(value : integer) return std_logic_vector is
    begin
        return std_logic_vector(to_unsigned(value, 8));
    end function;

    type rom is array(0 to 255) of std_logic_vector(25 downto 0);

    signal rom_data : rom := (
            FORMAT(IMM) & MOV & R0 & imm(10) & IGNORE,      -- R0=10
            FORMAT(BOTH) & ALU(ADD) & R1 & R0_8 & imm(20),  -- R1=30,R0=10
            FORMAT(REG) & ALU(SUB) & R2 & R1_8 & R0_8,      -- R2=20, R1=30, R0=10
            FORMAT(BOTH) & ALU(MUL) & R3 & R2_8 & imm(2),   -- R3=40, R2=20, R1=30, R0=10
            FORMAT(REG) & ALU(DIV) & R4 & R3_8 & R0_8,      -- R4=4, R3=40, R2=20, R1=30, R0=10
            FORMAT(REG) & ALU(RSHIFT) & R5 & R4_8 & IGNORE, -- R5=2, R4=4, R3=40, R2=20, R1=30, R0=10

            FORMAT(REG) & ALU(LSHIFT) & R5 & R5_8 & IGNORE, -- R5=4, R4=4, R3=40, R2=20, R1=30, R0=10
            FORMAT(REG) & MOV & R6 & R5_8 & IGNORE,         -- R6=4, R5=4, R4=4, R3=40, R2=20, R1=30, R0=10
            FORMAT(REG) & ALU(INC) & R7 & R6_8 & IGNORE,    -- R7=5, R6=4, R5=4, R4=4, R3=40, R2=20, R1=30, R0=10
            FORMAT(REG) & ALU(DEC) & R7 & R7_8 & IGNORE,    -- R7=4, R6=4, R5=4, R4=4, R3=40, R2=20, R1=30, R0=10

            RAM(FROM_REG) & R7 & addr(28) & IGNORE, -- R7=4, R6=4, R5=4, R4=4, R3=40, R2=20, R1=30, R0=10
            RAM(TO_REG) & R1 & addr(28) & IGNORE,   -- R7=4, R6=4, R5=4, R4=4, R3=40, R2=20, R1=4, R0=10

            FORMAT(REG) & ALU(LSHIFT) & R1 & R1_8 & IGNORE, -- R7=4, R6=4, R5=4, R4=4, R3=40, R2=20, R1=8, R0=10
            FORMAT(REG) & ALU(LSHIFT) & R1 & R1_8 & IGNORE, -- R7=4, R6=4, R5=4, R4=4, R3=40, R2=20, R1=16, R0=10

            FORMAT(REG) & PRINT & R1_8 & IGNORE,

            ---- Program list and mapping. total of 0 -> 8 programs.
            --FORMAT(IMM)     &           JUMP(ADDR)          &   addr(8)     &       IGNORE,    -- Selector
            --FORMAT(IMM)     &           JUMP(ADDR)          &   addr(24)    &       IGNORE,    -- Addition
            --FORMAT(IMM)     &           JUMP(ADDR)          &   addr(49)    &       IGNORE,    -- Multiplication
            --FORMAT(IMM)     &           JUMP(ADDR)          &   addr(74)    &       IGNORE,    -- Division
            --FORMAT(IMM)     &           JUMP(ADDR)          &   addr(99)    &       IGNORE,    -- Fibonacci
            --FORMAT(IMM)     &           JUMP(ADDR)          &   addr(24)    &       IGNORE,
            --FORMAT(IMM)     &           JUMP(ADDR)          &   addr(24)    &       IGNORE,
            --FORMAT(IMM)     &           JUMP(ADDR)          &   addr(24)    &       IGNORE,

            ---- Selector Program, starts at address 8 (8th instruction).
            --    -- Load the SW and print it
            --    LOAD_SW                         &   R0          &   IGNORE      &       IGNORE,
            --    FORMAT(REG)         &   PRINT                   &   R0_8        &       IGNORE,

            --    -- Load the KEY and compare it : Zero means pressed.
            --    LOAD_KEY                        &   R1          &   IGNORE      &       IGNORE,
            --    FORMAT(BOTH)    &   ALU(SUB)    &   R1          &   R1_8        &       imm(1),

            --    FORMAT(IMM)     &           JUMP(Z)             &   addr(0)     &       IGNORE,

            --    -- We pass this when pressed but to avoid looping we wait for unpressed to go further
            --    LOAD_PC                         &   R0          &   IGNORE      &       IGNORE,
            --    LOAD_KEY                        &   R1          &   IGNORE      &       IGNORE,
            --    FORMAT(BOTH)    &   ALU(SUB)    &   R1          &   R1_8        &       imm(1),

            --    FORMAT(REG)     &           JUMP(NZ)            &   R0_8        &       IGNORE,

            --    -- We get the current SW and we will perform some conditions to only validate
            --    -- a program number in [0, 7]
            --    LOAD_SW                         &   R0          &   IGNORE      &       IGNORE,

            --    FORMAT(BOTH)    &   ALU(SUB)    &   R1          &   R0_8        &       imm(0),
            --    FORMAT(IMM)     &       JUMP(NP)                &   addr(0)     &       IGNORE, -- restart from the begining if negative
            --    FORMAT(BOTH)    &   ALU(SUB)    &   R1          &   R0_8        &       imm(8),
            --    FORMAT(IMM)     &       JUMP(P)                 &   addr(0)     &       IGNORE, -- restart from the begining more than 7

            --    FORMAT(REG)     &       SPRINT                  &   R0_8        &       IGNORE,
            --    FORMAT(REG)     &       JUMP(ADDR)              &   R0_8        &       IGNORE,

            ---- Addition
            --    -- Load the SW and print it. Variable X
            --    LOAD_PC                         &   R7          &   IGNORE      &       IGNORE,
            --    LOAD_SW                         &   R0          &   IGNORE      &       IGNORE,
            --    FORMAT(REG)         &   PRINT                   &   R0_8        &       IGNORE,

            --    -- Load the KEY and compare it : Zero means pressed.
            --    LOAD_KEY                        &   R2          &   IGNORE      &       IGNORE,
            --    FORMAT(BOTH)    &   ALU(SUB)    &   R2          &   R2_8        &       imm(1),

            --    FORMAT(REG)     &           JUMP(Z)             &   R7_8        &       IGNORE,

            --    -- We pass this when pressed but to avoid looping we wait for unpressed to go further
            --    LOAD_PC                         &   R7          &   IGNORE      &       IGNORE,
            --    LOAD_KEY                        &   R2          &   IGNORE      &       IGNORE,
            --    FORMAT(BOTH)    &   ALU(SUB)    &   R2          &   R2_8        &       imm(1),

            --    FORMAT(REG)     &           JUMP(NZ)            &   R7_8        &       IGNORE,

            --    -- Load the SW and print it. Variable Y
            --    LOAD_PC                         &   R7          &   IGNORE      &       IGNORE,
            --    LOAD_SW                         &   R1          &   IGNORE      &       IGNORE,
            --    FORMAT(REG)         &   PRINT                   &   R1_8        &       IGNORE,

            --    -- Load the KEY and compare it : Zero means pressed.
            --    LOAD_KEY                        &   R2          &   IGNORE      &       IGNORE,
            --    FORMAT(BOTH)    &   ALU(SUB)    &   R2          &   R2_8        &       imm(1),

            --    FORMAT(REG)     &           JUMP(Z)             &   R7_8        &       IGNORE,

            --    -- We pass this when pressed but to avoid looping we wait for unpressed to go further
            --    LOAD_PC                         &   R7          &   IGNORE      &       IGNORE,
            --    LOAD_KEY                        &   R2          &   IGNORE      &       IGNORE,
            --    FORMAT(BOTH)    &   ALU(SUB)    &   R2          &   R2_8        &       imm(1),

            --    FORMAT(REG)     &           JUMP(NZ)            &   R7_8        &       IGNORE,

            --    FORMAT(REG)     &   ALU(ADD)    &   R2          &   R0_8        &       R1_8,
            --    FORMAT(REG)         &   PRINT                   &   R2_8        &       IGNORE,

            --    -- Loop at the end
            --    FORMAT(IMM)     &       SPRINT                  &   imm(0)      &       IGNORE,
            --    LOAD_PC                         &   R0          &   IGNORE      &       IGNORE,
            --    FORMAT(REG)     &           JUMP(NZ)            &   R0_8        &       IGNORE,

            ---- Multiplication
            --    -- Load the SW and print it. Variable X
            --    LOAD_PC                         &   R7          &   IGNORE      &       IGNORE,
            --    LOAD_SW                         &   R0          &   IGNORE      &       IGNORE,
            --    FORMAT(REG)         &   PRINT                   &   R0_8        &       IGNORE,

            --    -- Load the KEY and compare it : Zero means pressed.
            --    LOAD_KEY                        &   R2          &   IGNORE      &       IGNORE,
            --    FORMAT(BOTH)    &   ALU(SUB)    &   R2          &   R2_8        &       imm(1),

            --    FORMAT(REG)     &           JUMP(Z)             &   R7_8        &       IGNORE,

            --    -- We pass this when pressed but to avoid looping we wait for unpressed to go further
            --    LOAD_PC                         &   R7          &   IGNORE      &       IGNORE,
            --    LOAD_KEY                        &   R2          &   IGNORE      &       IGNORE,
            --    FORMAT(BOTH)    &   ALU(SUB)    &   R2          &   R2_8        &       imm(1),

            --    FORMAT(REG)     &           JUMP(NZ)            &   R7_8        &       IGNORE,

            --    -- Load the SW and print it. Variable Y
            --    LOAD_PC                         &   R7          &   IGNORE      &       IGNORE,
            --    LOAD_SW                         &   R1          &   IGNORE      &       IGNORE,
            --    FORMAT(REG)         &   PRINT                   &   R1_8        &       IGNORE,

            --    -- Load the KEY and compare it : Zero means pressed.
            --    LOAD_KEY                        &   R2          &   IGNORE      &       IGNORE,
            --    FORMAT(BOTH)    &   ALU(SUB)    &   R2          &   R2_8        &       imm(1),

            --    FORMAT(REG)     &           JUMP(Z)             &   R7_8        &       IGNORE,

            --    -- We pass this when pressed but to avoid looping we wait for unpressed to go further
            --    LOAD_PC                         &   R7          &   IGNORE      &       IGNORE,
            --    LOAD_KEY                        &   R2          &   IGNORE      &       IGNORE,
            --    FORMAT(BOTH)    &   ALU(SUB)    &   R2          &   R2_8        &       imm(1),

            --    FORMAT(REG)     &           JUMP(NZ)            &   R7_8        &       IGNORE,

            --    FORMAT(REG)     &   ALU(MUL)    &   R2          &   R0_8        &       R1_8,
            --    FORMAT(REG)         &   PRINT                   &   R2_8        &       IGNORE,

            --    -- Loop at the end
            --    FORMAT(IMM)     &       SPRINT                  &   imm(0)      &       IGNORE,
            --    LOAD_PC                         &   R0          &   IGNORE      &       IGNORE,
            --    FORMAT(REG)     &           JUMP(NZ)            &   R0_8        &       IGNORE,

            ---- Division
            --    -- Load the SW and print it. Variable X
            --    LOAD_PC                         &   R7          &   IGNORE      &       IGNORE,
            --    LOAD_SW                         &   R0          &   IGNORE      &       IGNORE,
            --    FORMAT(REG)         &   PRINT                   &   R0_8        &       IGNORE,

            --    -- Load the KEY and compare it : Zero means pressed.
            --    LOAD_KEY                        &   R2          &   IGNORE      &       IGNORE,
            --    FORMAT(BOTH)    &   ALU(SUB)    &   R2          &   R2_8        &       imm(1),

            --    FORMAT(REG)     &           JUMP(Z)             &   R7_8        &       IGNORE,

            --    -- We pass this when pressed but to avoid looping we wait for unpressed to go further
            --    LOAD_PC                         &   R7          &   IGNORE      &       IGNORE,
            --    LOAD_KEY                        &   R2          &   IGNORE      &       IGNORE,
            --    FORMAT(BOTH)    &   ALU(SUB)    &   R2          &   R2_8        &       imm(1),

            --    FORMAT(REG)     &           JUMP(NZ)            &   R7_8        &       IGNORE,

            --    -- Load the SW and print it. Variable Y
            --    LOAD_PC                         &   R7          &   IGNORE      &       IGNORE,
            --    LOAD_SW                         &   R1          &   IGNORE      &       IGNORE,
            --    FORMAT(REG)         &   PRINT                   &   R1_8        &       IGNORE,

            --    -- Load the KEY and compare it : Zero means pressed.
            --    LOAD_KEY                        &   R2          &   IGNORE      &       IGNORE,
            --    FORMAT(BOTH)    &   ALU(SUB)    &   R2          &   R2_8        &       imm(1),

            --    FORMAT(REG)     &           JUMP(Z)             &   R7_8        &       IGNORE,

            --    -- We pass this when pressed but to avoid looping we wait for unpressed to go further
            --    LOAD_PC                         &   R7          &   IGNORE      &       IGNORE,
            --    LOAD_KEY                        &   R2          &   IGNORE      &       IGNORE,
            --    FORMAT(BOTH)    &   ALU(SUB)    &   R2          &   R2_8        &       imm(1),

            --    FORMAT(REG)     &           JUMP(NZ)            &   R7_8        &       IGNORE,

            --    FORMAT(REG)     &   ALU(DIV)    &   R2          &   R0_8        &       R1_8,
            --    FORMAT(REG)         &   PRINT                   &   R2_8        &       IGNORE,

            --    -- Loop at the end
            --    FORMAT(IMM)     &       SPRINT                  &   imm(0)      &       IGNORE,
            --    LOAD_PC                         &   R0          &   IGNORE      &       IGNORE,
            --    FORMAT(REG)     &           JUMP(NZ)            &   R0_8        &       IGNORE,

            ---- Fibonacci
            --    -- Load the SW and print it. Variable N
            --    LOAD_PC                         &   R7          &   IGNORE      &       IGNORE,
            --    LOAD_SW                         &   R0          &   IGNORE      &       IGNORE,
            --    FORMAT(REG)         &   PRINT                   &   R0_8        &       IGNORE,

            --    -- Load the KEY and compare it : Zero means pressed.
            --    LOAD_KEY                        &   R2          &   IGNORE      &       IGNORE,
            --    FORMAT(BOTH)    &   ALU(SUB)    &   R2          &   R2_8        &       imm(1),

            --    FORMAT(REG)     &           JUMP(Z)             &   R7_8        &       IGNORE,

            --    -- We pass this when pressed but to avoid looping we wait for unpressed to go further
            --    LOAD_PC                         &   R7          &   IGNORE      &       IGNORE,
            --    LOAD_KEY                        &   R2          &   IGNORE      &       IGNORE,
            --    FORMAT(BOTH)    &   ALU(SUB)    &   R2          &   R2_8        &       imm(1),

            --    FORMAT(REG)     &           JUMP(NZ)            &   R7_8        &       IGNORE,

            --    -- Loop to calculate this term of fibonacci

            --    FORMAT(IMM)     &   ALU(ADD)    &   R1          &   imm(0)        &       imm(0), -- U_0 R1
            --    FORMAT(IMM)     &   ALU(ADD)    &   R2          &   imm(1)        &       imm(0), -- U_1 R2
            --    FORMAT(IMM)     &   ALU(ADD)    &   R3          &   imm(0)        &       imm(1), -- Counter 111

            --    -- Print the result, warning, if N == 0, we have to print 0, so we copy 0 to R2

            --    LOAD_PC                         &   R7          &   IGNORE      &       IGNORE, -- Load the current address to jump further
            --    FORMAT(BOTH)    &   ALU(ADD)    &   R7          &   R7_8        &       imm(6), -- Further is 6 instructions after the LOAD_PC
            --    FORMAT(BOTH)    &   ALU(SUB)    &   R6          &   R0_8        &       imm(0), -- check if N != 0
            --    FORMAT(REG)     &           JUMP(NZ)            &   R7_8        &       IGNORE,
            --    FORMAT(REG)     &   MOV         &   R2          &   R1_8        &       IGNORE, -- Further, only if N == 0, copy R1 to R2 (ie U_0 to U_1)
            --    FORMAT(IMM)     &           JUMP(ADDR)          &   imm(131)    &       IGNORE,

            --    -- Print the result, warning, if N == 1, we have to skip the loop

            --    LOAD_PC                         &   R7          &   IGNORE      &       IGNORE, -- Load the current address to jump further
            --    FORMAT(BOTH)    &   ALU(ADD)    &   R7          &   R7_8        &       imm(5), -- Further is 5 instructions after the LOAD_PC
            --    FORMAT(BOTH)    &   ALU(SUB)    &   R6          &   R0_8        &       imm(1), -- check if N != 1
            --    FORMAT(REG)     &           JUMP(NZ)            &   R7_8        &       IGNORE,
            --    FORMAT(IMM)     &           JUMP(ADDR)          &   imm(131)    &       IGNORE,

            --    -- Loop to calculate the next term

            --    LOAD_PC                         &   R7          &   IGNORE      &       IGNORE, -- begining of the loop 123

            --    FORMAT(REG)     &   MOV         &   R4          &   R2_8        &       IGNORE,
            --    FORMAT(REG)     &   ALU(ADD)    &   R5          &   R4_8        &       R1_8,

            --    FORMAT(REG)     &   MOV         &   R1          &   R4_8        &       IGNORE,
            --    FORMAT(REG)     &   MOV         &   R2          &   R5_8        &       IGNORE,

            --    FORMAT(BOTH)    &   ALU(ADD)    &   R3          &   R3_8        &       imm(1), -- Counter
            --    FORMAT(REG)     &   ALU(SUB)    &   R6          &   R3_8        &       R0_8, -- Compare N to Counter
            --    FORMAT(REG)     &           JUMP(NP)            &   R7_8        &       IGNORE, -- If N > Counter, loop


            --    FORMAT(REG)         &   PRINT                   &   R2_8        &       IGNORE, -- Final result should be in R2 -- 131

            --    -- Loop at the end
            --    FORMAT(IMM)     &       SPRINT                  &   imm(0)      &       IGNORE,
            --    LOAD_PC                         &   R0          &   IGNORE      &       IGNORE,
            --    FORMAT(REG)     &           JUMP(NZ)            &   R0_8        &       IGNORE,

        others => NOP
    );

begin
    process (rst, clk)
    begin
        if rst /= '1' then
            if rising_edge(clk) then
                if en = '1' then
                    data <= rom_data(to_integer(unsigned(address)));
                end if;

            end if;
        end if;

    end process;

end architecture;
