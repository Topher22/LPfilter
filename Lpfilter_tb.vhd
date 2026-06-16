-------------------------------------------------------------------------------
--
-- Title       : Lpfilter_tb
-- Design      : LPfilter
-- Author      : tofarajo@gmail.com
-- Company     : Technical University Munich
--
-------------------------------------------------------------------------------
--
-- File        : c:/My_Designs/LPfilter/src/Lpfilter_tb.vhd
-- Generated   : Mon Jun 15 13:52:11 2026
-- From        : Interface description file
-- By          : ItfToHdl ver. 1.0
--
-------------------------------------------------------------------------------
--
-- Description : 
--
-------------------------------------------------------------------------------
-- =========================================================================
-- LPfilter_9cycle_tb.vhd
-- Testbench for 9-tap Pipelined FIR Filter
--
-- Purpose:
--   Apply test stimuli and capture output waveforms
--   Compare against MATLAB reference model
-- =========================================================================

-- =========================================================================
-- LPfilter_9cycle_tb.vhd.vhd
-- 9-tap FIR Low-Pass Filter — 9-Stage Pipelined Architecture
-- =========================================================================

-- =========================================================================
-- fir_filter_pipelined_9cycle_tb.vhd
-- Testbench for 9-tap Pipelined FIR Filter
--
-- Purpose:
--   Apply test stimuli and capture output waveforms
-- =========================================================================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity LPfilter_tb is
end entity LPfilter_tb;

architecture tb of LPfilter_tb is

    -- =====================================================================
    -- Component Declaration
    -- =====================================================================
    component LPfilter is
        port (
            clk       : in  std_logic;
            rst       : in  std_logic;
            x_in      : in  signed(15 downto 0);
            valid_in  : in  std_logic;
            y_out     : out signed(15 downto 0);
            valid_out : out std_logic
        );
    end component;

    -- =====================================================================
    -- Test Signals
    -- =====================================================================
    signal clk       : std_logic := '0';
    signal rst       : std_logic := '1';
    signal x_in      : signed(15 downto 0) := (others => '0');
    signal valid_in  : std_logic := '0';
    signal y_out     : signed(15 downto 0);
    signal valid_out : std_logic;

    -- Clock period
    constant CLK_PERIOD : time := 10 ns;

begin

    -- =====================================================================
    -- DUT Instantiation
    -- =====================================================================
    dut : LPfilter
        port map (
            clk       => clk,
            rst       => rst,
            x_in      => x_in,
            valid_in  => valid_in,
            y_out     => y_out,
            valid_out => valid_out
        );

    -- =====================================================================
    -- Clock Generator
    -- =====================================================================
    clk <= not clk after CLK_PERIOD / 2;

    -- =====================================================================
    -- Main Testbench Process
    -- =====================================================================
    process
        variable phase : real;
        variable value : real;
    begin
        -- =================================================================
        -- Reset Sequence
        -- =================================================================
        rst <= '1';
        valid_in <= '0';
        x_in <= (others => '0');
        wait for 3 * CLK_PERIOD;
        rst <= '0';
        wait for CLK_PERIOD;

        -- =================================================================
        -- TC-01: 200 Hz Sine Wave
        -- Fs = 8000 Hz, so 200 Hz = 40 samples per period
        -- =================================================================
        report "Starting TC-01: 200 Hz Sine Wave (Passband)";
        for sample in 0 to 79 loop
            phase := 2.0 * MATH_PI * real(sample mod 40) / 40.0;
            value := sin(phase);
            x_in <= to_signed(integer(value * 16000.0), 16);
            valid_in <= '1';
            wait for CLK_PERIOD;
        end loop;
        valid_in <= '0';
        wait for 20 * CLK_PERIOD;

        -- =================================================================
        -- TC-02: 2000 Hz Sine Wave
        -- Fs = 8000 Hz, so 2000 Hz = 4 samples per period
        -- =================================================================
        report "Starting TC-02: 2000 Hz Sine Wave (Stopband)";
        rst <= '1';
        wait for CLK_PERIOD;
        rst <= '0';
        wait for CLK_PERIOD;
        
        for sample in 0 to 79 loop
            phase := 2.0 * MATH_PI * real(sample mod 4) / 4.0;
            value := sin(phase);
            x_in <= to_signed(integer(value * 16000.0), 16);
            valid_in <= '1';
            wait for CLK_PERIOD;
        end loop;
        valid_in <= '0';
        wait for 20 * CLK_PERIOD;

        -- =================================================================
        -- TC-03: Mixed 200 Hz + 2000 Hz
        -- =================================================================
        report "Starting TC-03: Mixed 200 Hz + 2000 Hz";
        rst <= '1';
        wait for CLK_PERIOD;
        rst <= '0';
        wait for CLK_PERIOD;
        
        for sample in 0 to 79 loop
            phase := 2.0 * MATH_PI * real(sample mod 40) / 40.0;
            value := (sin(phase) * 0.5) + (sin(phase * 10.0) * 0.5);
            x_in <= to_signed(integer(value * 16000.0), 16);
            valid_in <= '1';
            wait for CLK_PERIOD;
        end loop;
        valid_in <= '0';
        wait for 20 * CLK_PERIOD;

        -- =================================================================
        -- TC-04: Maximum Amplitude (Overflow Check)
        -- =================================================================
        report "Starting TC-04: Maximum Amplitude (Overflow Check)";
        rst <= '1';
        wait for CLK_PERIOD;
        rst <= '0';
        wait for CLK_PERIOD;
        
        for sample in 0 to 49 loop
            x_in <= to_signed(30000, 16);
            valid_in <= '1';
            wait for CLK_PERIOD;
        end loop;
        valid_in <= '0';
        wait for 20 * CLK_PERIOD;

        -- =================================================================
        -- TC-05: Impulse Response (Latency Check)
        -- =================================================================
        report "Starting TC-05: Impulse Response (Latency)";
        rst <= '1';
        wait for CLK_PERIOD;
        rst <= '0';
        wait for CLK_PERIOD;
        
        -- Single impulse
        x_in <= to_signed(32767, 16);
        valid_in <= '1';
        wait for CLK_PERIOD;
        
		-- Zeros after impulse — keep valid_in HIGH to flush pipeline
		x_in <= (others => '0');
		valid_in <= '1';              -- ? pipeline keeps running
		for sample in 1 to 19 loop
		    wait for CLK_PERIOD;
		end loop;
		valid_in <= '0';              -- drop valid only after flush

        -- =================================================================
        -- End of Simulation
        -- =================================================================
        report "Testbench complete";
        wait;
    end process;

end architecture tb;