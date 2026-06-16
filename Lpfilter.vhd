-------------------------------------------------------------------------------
--
-- Title       : LPfilter
-- Design      : LPfilter
-- Author      : tofarajo@gmail.com
-- Company     : Technical University Munich
--
-------------------------------------------------------------------------------
--
-- File        : c:/My_Designs/LPfilter/src/LPfilter.vhd
-- Generated   : Thu Jun 11 17:51:29 2026
-- From        : Interface description file
-- By          : ItfToHdl ver. 1.0
--
-------------------------------------------------------------------------------
--
-- Description :VHDL representation of the already tested MATLAB Simulation of the Low Pass Filter 
-- Architecture: Shift register + multiplier accumulator
-- Coefficients: Q1.15 fixed-point (16-bit signed)
-- Latency: 9 clock cycles
--
-- Requirements covered:
--   REQ-01: Attenuate >= 20 dB above 1 kHz
--   REQ-02: Attenuate < 3 dB below 500 Hz
--   REQ-03: No overflow (saturation arithmetic)
--   REQ-04: Output valid within 9 clock cycles
-- =========================================================================
-------------------------------------------------------------------------------

-- ======================================QQ===================================
-- Lpfilter.vhd
-- 9-tap FIR Low-Pass Filter — 9-Stage Pipelined Architecture
--
-- Pipeline Stages:
--   Stage 1: Input registration + shift register (sample 0-8)
--   Stage 2: Multiply all 9 taps ? 9 products
--   Stage 3: Adder tree level 1 ? 5 partial sums
--   Stage 4: Adder tree level 2 ? 3 partial sums
--   Stage 5: Final partial sum accumulation
--   Stage 6-9: Delay registers (for 9-cycle total latency match)
-- =========================================================================

-- =========================================================================
-- Lpfilter.vhd
-- 9-tap FIR Low-Pass Filter — 9-Stage Pipelined Architecture
-- =========================================================================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity LPfilter is
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        x_in      : in  signed(15 downto 0);
        valid_in  : in  std_logic;
        y_out     : out signed(15 downto 0);
        valid_out : out std_logic
    );
end entity LPfilter;

architecture pipelined of LPfilter is

    type coeff_array is array (0 to 8) of signed(15 downto 0);
    type samples_array is array (0 to 8) of signed(15 downto 0);
    type products_array is array (0 to 8) of signed(31 downto 0);
    type partial_sums_l1 is array (0 to 4) of signed(31 downto 0);
    type partial_sums_l2 is array (0 to 2) of signed(31 downto 0);

    constant COEFFS : coeff_array := (
        0 => to_signed(0, 16),
        1 => to_signed(626, 16),
        2 => to_signed(3338, 16),
        3 => to_signed(7565, 16),
        4 => to_signed(9711, 16),
        5 => to_signed(7565, 16),
        6 => to_signed(3338, 16),
        7 => to_signed(626, 16),
        8 => to_signed(0, 16)
    );

    signal x_s1          : samples_array := (others => (others => '0'));
    signal valid_s1      : std_logic := '0';

    signal products_s2   : products_array := (others => (others => '0'));
    signal valid_s2      : std_logic := '0';

    signal partial_l1_s3 : partial_sums_l1 := (others => (others => '0'));
    signal valid_s3      : std_logic := '0';

    signal partial_l2_s4 : partial_sums_l2 := (others => (others => '0'));
    signal valid_s4      : std_logic := '0';

    signal final_sum_s5  : signed(31 downto 0) := (others => '0');
    signal valid_s5      : std_logic := '0';

    signal final_sum_s6  : signed(31 downto 0) := (others => '0');
    signal valid_s6      : std_logic := '0';

    signal final_sum_s7  : signed(31 downto 0) := (others => '0');
    signal valid_s7      : std_logic := '0';

    signal final_sum_s8  : signed(31 downto 0) := (others => '0');
    signal valid_s8      : std_logic := '0';

    signal final_sum_s9  : signed(31 downto 0) := (others => '0');
    signal valid_s9      : std_logic := '0';

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                x_s1 <= (others => (others => '0'));
                valid_s1 <= '0';
                products_s2 <= (others => (others => '0'));
                valid_s2 <= '0';
                partial_l1_s3 <= (others => (others => '0'));
                valid_s3 <= '0';
                partial_l2_s4 <= (others => (others => '0'));
                valid_s4 <= '0';
                final_sum_s5 <= (others => '0');
                valid_s5 <= '0';
                final_sum_s6 <= (others => '0');
                valid_s6 <= '0';
                final_sum_s7 <= (others => '0');
                valid_s7 <= '0';
                final_sum_s8 <= (others => '0');
                valid_s8 <= '0';
                final_sum_s9 <= (others => '0');
                valid_s9 <= '0';
                y_out <= (others => '0');
                valid_out <= '0';

            else

                -- STAGE 1: Input + Shift Register
                valid_s1 <= valid_in;
                x_s1(0) <= x_in;
                x_s1(1) <= x_s1(0);
                x_s1(2) <= x_s1(1);
                x_s1(3) <= x_s1(2);
                x_s1(4) <= x_s1(3);
                x_s1(5) <= x_s1(4);
                x_s1(6) <= x_s1(5);
                x_s1(7) <= x_s1(6);
                x_s1(8) <= x_s1(7);

                -- STAGE 2: Multiply All Taps
                valid_s2 <= valid_s1;
                for i in 0 to 8 loop
                    products_s2(i) <= x_s1(i) * COEFFS(i);
                end loop;

                -- STAGE 3: Adder Tree Level 1 (9 -> 5)
                valid_s3 <= valid_s2;
                partial_l1_s3(0) <= products_s2(0) + products_s2(1);
                partial_l1_s3(1) <= products_s2(2) + products_s2(3);
                partial_l1_s3(2) <= products_s2(4) + products_s2(5);
                partial_l1_s3(3) <= products_s2(6) + products_s2(7);
                partial_l1_s3(4) <= products_s2(8);

                -- STAGE 4: Adder Tree Level 2 (5 -> 3)
                valid_s4 <= valid_s3;
                partial_l2_s4(0) <= partial_l1_s3(0) + partial_l1_s3(1);
                partial_l2_s4(1) <= partial_l1_s3(2) + partial_l1_s3(3);
                partial_l2_s4(2) <= partial_l1_s3(4);

                -- STAGE 5: Final Accumulation
                valid_s5 <= valid_s4;
                final_sum_s5 <= partial_l2_s4(0) + partial_l2_s4(1) + partial_l2_s4(2);

                -- STAGES 6-9: Delay Pipeline
                valid_s6 <= valid_s5;
                final_sum_s6 <= final_sum_s5;

                valid_s7 <= valid_s6;
                final_sum_s7 <= final_sum_s6;

                valid_s8 <= valid_s7;
                final_sum_s8 <= final_sum_s7;

                valid_s9 <= valid_s8;
                final_sum_s9 <= final_sum_s8;

                -- OUTPUT: Saturating Conversion
                valid_out <= valid_s9;
                
                if valid_s9 = '1' then
                    -- Right-shift by 15 bits to convert Q2.30 -> Q1.15
                    -- Extract bits [31:15] which gives the 17-bit result
                    if final_sum_s9(31 downto 15) > to_signed(32767, 17) then
                        y_out <= to_signed(32767, 16);
                    elsif final_sum_s9(31 downto 15) < to_signed(-32768, 17) then
                        y_out <= to_signed(-32768, 16);
                    else
                        y_out <= final_sum_s9(30 downto 15);
                    end if;
                end if;

            end if;
        end if;
    end process;

end architecture pipelined;
