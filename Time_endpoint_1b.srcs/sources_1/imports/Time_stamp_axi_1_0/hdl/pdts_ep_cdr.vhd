-- pdts_ep_cdr
--
-- Clock-data recovery block for PDTS endpoint
--
-- Dave Newbold, December 2021

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

library unisim;
use unisim.VComponents.all;

use work.pdts_clock_defs.all;

entity pdts_ep_cdr is
	generic(
		USE_EXT_PLL: boolean := false; -- Assert to enable use of external clock
		EXT_PLL_DIV: positive := 2 -- Division factor for PLL clock return (keep at 2 for no PLL)
	);
	port(
	   pl_clk0: in std_logic;
		d: in std_logic; -- Timing signal input
		los: in std_logic; -- LOS input
		rclko: out std_logic; -- Recovered clock output
		rclki: in std_logic := '0'; -- Recovered clock return
		rsti: in std_logic := '0'; -- Async reset
		clko: out std_logic; -- Output clock
		clko4x: out std_logic; -- Output sample clock
		clko2x: out std_logic; -- 2x clock for user application
		rsto: out std_logic; -- clko domain reset (clko domain)
		cdr_rst: in std_logic; -- CDR block resync (clko domain)
		q: out std_logic; -- Data stream (clko domain)
		locked: out std_logic; -- Asserted when clko good (clko domain)
		phase: in std_logic_vector(11 downto 0); -- Phase setting (clko domain)
		phase_done: out std_logic; -- Phase done flag (clko domain)
		dbg: out std_logic_vector(11 downto 0) -- CDR debug information (clko domain)
	);

end pdts_ep_cdr;

architecture rtl of pdts_ep_cdr is

	signal bclk, bclk_f, clkin, clkfb, clku, clku4x, clku2x: std_logic;
	signal mlock, clk, clk4x, clk2x, psincdec, psen, psdone: std_logic;
	signal rsta, rst, rstm: std_logic;
	signal cphase: std_logic_vector(11 downto 0);
	signal psact, psd: std_logic;
	signal pl_clk: std_logic;
	
	attribute ASYNC_REG: string;
	attribute ASYNC_REG of rsta, rst: signal is "yes";
	
	attribute MARK_DEBUG: string;
	attribute MARK_DEBUG of los, mlock, rst, cdr_rst, rsti, phase, psincdec, psen, psdone, cphase, psact, psd: signal is "TRUE";

begin

-- Clock divider

	bufr0: BUFR
		generic map(
			BUFR_DIVIDE => "2"
		)
		port map(
			i => d,
			o => bclk,
			ce => '1',
			clr => '0'
		);

-- Clock forwarding to PLL; user must instantiate an OBUFDS if differential clock output
		
	bufgb: BUFG -- Needed for case where clock-forwarding ODDR is not in the same bank as the BUFR
		port map(
			i => bclk,
			o => bclk_f
	);
	
	
	
	oddr_rclko : ODDRE1
   generic map (
      IS_C_INVERTED => '0',            -- Optional inversion for C
      IS_D1_INVERTED => '0',           -- Unsupported, do not use
      IS_D2_INVERTED => '0',           -- Unsupported, do not use
      SIM_DEVICE => "ULTRASCALE_PLUS", -- Set the device version for simulation functionality (ULTRASCALE,
                                       -- ULTRASCALE_PLUS, ULTRASCALE_PLUS_ES1, ULTRASCALE_PLUS_ES2)
      SRVAL => '1'                     -- Initializes the ODDRE1 Flip-Flops to the specified value ('0', '1')
   )
   port map (
      Q => rclko,   -- 1-bit output: Data output to IOB
      C => bclk_f,   -- 1-bit input: High-speed clock input
      D1 => '0', -- 1-bit input: Parallel data input 1
      D2 => '1', -- 1-bit input: Parallel data input 2
      SR => '0'  -- 1-bit input: Active-High Async Reset
   );
	
	
	
	
	
	--oddr_rclko: ODDR -- Feedback clock, not through MMCM
		--port map(
			--q => rclko,
			--c => bclk_f,
			--ce => '1',
			--d1 => '0',
			--d2 => '1',
			--r => '0',
			--s => '0'
		--);

-- PLL


	clkin <= rclki when USE_EXT_PLL else bclk;
	rstm <= rsti or los;
    pl_buff: BUFG
    		port map(
			i => pl_clk0,
			o => pl_clk
	);

  







 --mmcm : MMCME3_ADV
  -- generic map (
     -- BANDWIDTH => "OPTIMIZED",        -- Jitter programming (HIGH, LOW, OPTIMIZED)
      --CLKFBOUT_MULT_F => real(EP_VCO_RATIO * EXT_PLL_DIV),          -- Multiply value for all CLKOUT (2.000-64.000)
     -- CLKFBOUT_PHASE => 0.0,           -- Phase offset in degrees of CLKFB (-360.000-360.000)
      -- CLKIN_PERIOD: Input clock period in ns units, ps resolution (i.e., 33.333 is 30 MHz).
      --CLKIN1_PERIOD => (1000.0 * real(EXT_PLL_DIV) / CLK_FREQ),
      --CLKIN2_PERIOD => 0.0,
     -- CLKOUT0_DIVIDE_F =>real(EP_VCO_RATIO),         -- Divide amount for CLKOUT0 (1.000-128.000)
      -- CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for CLKOUT outputs (0.001-0.999).
     -- CLKOUT0_DUTY_CYCLE => 0.5,
      --CLKOUT1_DUTY_CYCLE => 0.5,
     -- CLKOUT2_DUTY_CYCLE => 0.5,
     -- CLKOUT3_DUTY_CYCLE => 0.5,
     -- CLKOUT4_DUTY_CYCLE => 0.5,
     -- CLKOUT5_DUTY_CYCLE => 0.5,
     -- CLKOUT6_DUTY_CYCLE => 0.5,
      -- CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for CLKOUT outputs (-360.000-360.000).
     -- CLKOUT0_PHASE => 0.0,
     -- CLKOUT1_PHASE => 0.0,
     -- CLKOUT2_PHASE => 0.0,
      --CLKOUT3_PHASE => 0.0,
      --CLKOUT4_PHASE => 0.0,
     --CLKOUT5_PHASE => 0.0,
     -- CLKOUT6_PHASE => 0.0,
      -- CLKOUT1_DIVIDE - CLKOUT6_DIVIDE: Divide amount for CLKOUT (1-128)
  --    CLKOUT1_DIVIDE => EP_VCO_RATIO / 4,
     -- CLKOUT2_DIVIDE => EP_VCO_RATIO / 2,
     -- CLKOUT3_DIVIDE => 1,
    --  CLKOUT4_CASCADE => "FALSE",
     -- CLKOUT4_DIVIDE => 1,
     -- CLKOUT5_DIVIDE => 1,
     -- CLKOUT6_DIVIDE => 1,
     -- COMPENSATION => "AUTO",          -- AUTO, BUF_IN, EXTERNAL, INTERNAL, ZHOLD
      --DIVCLK_DIVIDE => 1,              -- Master division value (1-106)
      -- Programmable Inversion Attributes: Specifies built-in programmable inversion on specific pins
     -- IS_CLKFBIN_INVERTED => '0',      -- Optional inversion for CLKFBIN
     -- IS_CLKIN1_INVERTED => '0',       -- Optional inversion for CLKIN1
     -- IS_CLKIN2_INVERTED => '0',       -- Optional inversion for CLKIN2
     -- IS_CLKINSEL_INVERTED => '0',     -- Optional inversion for CLKINSEL
     --- IS_PSEN_INVERTED => '0',         -- Optional inversion for PSEN
     -- IS_PSINCDEC_INVERTED => '0',     -- Optional inversion for PSINCDEC
     -- IS_PWRDWN_INVERTED => '0',       -- Optional inversion for PWRDWN
     -- IS_RST_INVERTED => '0',          -- Optional inversion for RST
      -- REF_JITTER: Reference input jitter in UI (0.000-0.999).
     -- REF_JITTER1 => 0.0,
     -- REF_JITTER2 => 0.0,
     -- STARTUP_WAIT => "FALSE",         -- Delays DONE until MMCM is locked (FALSE, TRUE)
      -- Spread Spectrum: Spread Spectrum Attributes.
    --  SS_EN => "FALSE",                -- Enables spread spectrum (FALSE, TRUE)
     -- SS_MODE => "CENTER_HIGH",        -- CENTER_HIGH, CENTER_LOW, DOWN_HIGH, DOWN_LOW
    --  SS_MOD_PERIOD => 10000,          -- Spread spectrum modulation period (ns) (4000-40000)
      -- USE_FINE_PS: Fine phase shift enable (TRUE/FALSE)
     -- CLKFBOUT_USE_FINE_PS => "TRUE",
     -- CLKOUT0_USE_FINE_PS => "TRUE",
     -- CLKOUT1_USE_FINE_PS => "TRUE",
     -- CLKOUT2_USE_FINE_PS => "TRUE"
     -- CLKOUT3_USE_FINE_PS => "FALSE",
     -- CLKOUT4_USE_FINE_PS => "FALSE",
     -- CLKOUT5_USE_FINE_PS => "FALSE",
     -- CLKOUT6_USE_FINE_PS => "FALSE" 
 --  )
  -- port map (
      -- Clock Outputs outputs: User configurable clock outputs
    --  CLKOUT0 => clku,           -- 1-bit output: CLKOUT0
    --  CLKOUT0B => CLKOUT0B,         -- 1-bit output: Inverted CLKOUT0.
     -- CLKOUT1 => clku4x,           -- 1-bit output: Primary clock
   --   CLKOUT1B => CLKOUT1B,         -- 1-bit output: Inverted CLKOUT1
      --CLKOUT2 => clku2x,           -- 1-bit output: CLKOUT2
    --  CLKOUT2B => CLKOUT2B,         -- 1-bit output: Inverted CLKOUT2
    --  CLKOUT3 => CLKOUT3,           -- 1-bit output: CLKOUT3
     -- CLKOUT3B => CLKOUT3B,         -- 1-bit output: Inverted CLKOUT3
     -- CLKOUT4 => CLKOUT4,           -- 1-bit output: CLKOUT4
     -- CLKOUT5 => CLKOUT5,           -- 1-bit output: CLKOUT5
     -- CLKOUT6 => CLKOUT6,           -- 1-bit output: CLKOUT6
      -- DRP Ports outputs: Dynamic reconfiguration ports
    --  DO => DO,                     -- 16-bit output: DRP data
     -- DRDY => DRDY,                 -- 1-bit output: DRP ready
      -- Dynamic Phase Shift Ports outputs: Ports used for dynamic phase shifting of the outputs
     -- PSDONE => PSDONE,             -- 1-bit output: Phase shift done
      -- Feedback outputs: Clock feedback ports
      --CLKFBOUT => CLKFBOUT,         -- 1-bit output: Feedback clock
      --CLKFBOUTB => CLKFBOUTB,       -- 1-bit output: Inverted CLKFBOUT
      -- Status Ports outputs: MMCM status ports
      --CDDCDONE => CDDCDONE,         -- 1-bit output: Clock dynamic divide done
     -- CLKFBSTOPPED => CLKFBSTOPPED, -- 1-bit output: Feedback clock stopped
      --CLKINSTOPPED => CLKINSTOPPED, -- 1-bit output: Input clock stopped
     -- LOCKED => mlock,            -- 1-bit output: LOCK
     --CDDCREQ => '0',           -- 1-bit input: Request to dynamic divide clock
      -- Clock Inputs inputs: Clock inputs
      --CLKIN1 => bclk_f,  --clkin ---1-bit input: Primary clock
     -- CLKIN2 => '0',             -- 1-bit input: Secondary clock
      -- Control Ports inputs: MMCM control ports
    --  CLKINSEL => '1',         -- 1-bit input: Clock select, High=CLKIN1 Low=CLKIN2
     -- PWRDWN => '0',             -- 1-bit input: Power-down
     -- RST => rstm,                   -- 1-bit input: Reset
      -- DRP Ports inputs: Dynamic reconfiguration ports
     -- DADDR => "0000000",               -- 7-bit input: DRP address
     -- DCLK => '0',                 -- 1-bit input: DRP clock
     -- DEN => '0',                 -- 1-bit input: DRP enable
      --DI => X"0000",                    -- 16-bit input: DRP data
      --DWE => '0',                  -- 1-bit input: DRP write enable
      -- Dynamic Phase Shift Ports inputs: Ports used for dynamic phase shifting of the outputs
    --  PSCLK => clk,             -- 1-bit input: Phase shift clock
     -- PSEN => PSEN,                 -- 1-bit input: Phase shift enable
     -- PSINCDEC => PSINCDEC,         -- 1-bit input: Phase shift increment/decrement
      -- Feedback inputs: Clock feedback ports
      --CLKFBIN => clkfb            -- 1-bit input: Feedback clock
  -- );



















	mmcm: MMCME2_ADV
		generic map(
			CLKIN1_PERIOD => (1000.0 * real(EXT_PLL_DIV) / CLK_FREQ), -- Input clock (62.5MHz)
			CLKFBOUT_MULT_F => real(EP_VCO_RATIO * EXT_PLL_DIV), -- VCO around 1GHz
			CLKOUT0_DIVIDE_F => real(EP_VCO_RATIO), -- System clock (62.5MHz)
			CLKOUT1_DIVIDE => EP_VCO_RATIO / 4, -- 4x system clock (250MHz)
		CLKOUT2_DIVIDE => EP_VCO_RATIO / 2, -- 2x system clock (125MHz)
			CLKOUT0_USE_FINE_PS => true,
			CLKOUT1_USE_FINE_PS => true,
			CLKOUT2_USE_FINE_PS => true
		)
		port map(
			clkin1 => clkin,
			clkin2 => '0',
			clkfbin => clkfb,
			clkout0 => clku,
			clkout1 => clku4x,
			clkout2 => clku2x,
			clkfbout => clkfb,
			locked => mlock,
			rst => rstm,
			pwrdwn => '0',
			clkinsel => '0',------ CHANGED THIS FROM ONE.
			daddr => "0000000",
			di => X"0000",
			dwe => '0',
			den => '0',
			dclk => '0',
			psincdec => psincdec,
			psen => psen,
			psclk => clk,
			psdone => psdone
		);
		
	bufg0: BUFG
		port map(
			i => clku,
			o => clk
	);
	
	clko <= clk;

	bufg4x: BUFG
		port map(
			i => clku4x,
			o => clk4x
	);
	
	clko4x <= clk4x;
	
	bufg2x: BUFG
		port map(
			i => clku2x,
			o => clk2x
	);
	
	clko2x <= clk2x;













-- Reset

	rsta <= not mlock when rising_edge(clk); -- CDC; different clocks
	rst <= rsta when rising_edge(clk); -- Synchroniser FF
	rsto <= rst;

-- Phase shift

	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				cphase <= X"000";
				psact <= '0';
			else
				if psact = '0' then
					if psd = '0' then
						psen <= '1';
						psact <= '1';
						if unsigned(cphase) < unsigned(phase) then
							psincdec <= '1';
						else
							psincdec <= '0';
						end if;
					end if;
				elsif psdone = '1' then
					if psincdec = '1' then
						cphase <= std_logic_vector(unsigned(cphase) + 1);
					else
						cphase <= std_logic_vector(unsigned(cphase) - 1);
					end if;
					psact <= '0';
				end if;
			end if;
		end if;
	end process;
	
	psd <= '1' when cphase = phase else '0';
	phase_done <= psd;

-- Data sampler

	sm: entity work.pdts_cdr_sampler
		port map(
			clk => clk,
			clk4x => clk4x,
			rst => rst,
			resync => cdr_rst,
			d => d,
			q => q,
			locked => locked,
			dbg => dbg
		);

end rtl;