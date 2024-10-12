library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity top_vga_driver is
    Port (
        clk : in std_logic;

        vgaRed : out std_logic_vector(3 downto 0);
        vgaGreen : out std_logic_vector(3 downto 0);
        vgaBlue : out std_logic_vector(3 downto 0);
        Hsync : out std_logic;
        Vsync : out std_logic
    );
end top_vga_driver;

architecture rtl of top_vga_driver is

CONSTANT H_LIMIT    : natural := 800;
CONSTANT H_RES      : natural := 640;
CONSTANT H_L_BORDER : natural := 144;

CONSTANT V_LIMIT    : natural := 525;
CONSTANT V_RES      : natural := 480;
CONSTANT V_T_BORDER : natural := 35;


signal pixel_clk        : std_logic;
signal pixel_clk_locked : std_logic;
signal pixel_clk_fb : std_logic;

signal h_counter : unsigned(9 downto 0);
signal v_counter : unsigned(9 downto 0);

begin

    -- PLLE2_BASE: Base Phase Locked Loop (PLL)
--             7 Series
-- Xilinx HDL Language Template, version 2024.1

PLLE2_BASE_inst : PLLE2_BASE
generic map (
   BANDWIDTH            => "OPTIMIZED",  -- OPTIMIZED, HIGH, LOW
   CLKFBOUT_MULT        => 8,        -- Multiply value for all CLKOUT, (2-64)
   CLKOUT0_DIVIDE       => 32,

   CLKFBOUT_PHASE       => 0.0,     -- Phase offset in degrees of CLKFB, (-360.000-360.000).
   CLKIN1_PERIOD        => 10.0,      -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
   -- CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for each CLKOUT (1-128)

   -- CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for each CLKOUT (0.001-0.999).
   CLKOUT0_DUTY_CYCLE   => 0.5,

   -- CLKOUT0_PHASE - CLKOUT5_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
   CLKOUT0_PHASE        => 0.0,

   DIVCLK_DIVIDE        => 1,        -- Master division value, (1-56)
   REF_JITTER1          => 0.0,        -- Reference input jitter in UI, (0.000-0.999).
   STARTUP_WAIT         => "FALSE"    -- Delay DONE until PLL Locks, ("TRUE"/"FALSE")
)
port map (
   -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
   CLKOUT0  => pixel_clk,   -- 1-bit output: CLKOUT0

   -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
   CLKFBOUT => pixel_clk_fb, -- 1-bit output: Feedback clock
   LOCKED   => pixel_clk_locked,     -- 1-bit output: LOCK
   CLKIN1   => clk,     -- 1-bit input: Input clock
   -- Control Ports: 1-bit (each) input: PLL control ports
   PWRDWN   => '0',     -- 1-bit input: Power-down
   RST      => '0',           -- 1-bit input: Reset
   -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
   CLKFBIN  => pixel_clk_fb    -- 1-bit input: Feedback clock
);

-- End of PLLE2_BASE_inst instantiation

h_v_counters_proc : process(pixel_clk) is
begin
    if rising_edge(pixel_clk) then
        h_counter <= h_counter + 1;

        if h_counter = H_LIMIT - 1 then
            h_counter <= (others => '0');
            v_counter <= v_counter + 1;

            if v_counter = V_LIMIT - 1 then
                v_counter <= (others => '0');
            end if;
        end if;
    end if;
end process;

h_v_sync_proc : process(pixel_clk) is
begin
    if rising_edge(pixel_clk) then
        if h_counter = H_LIMIT - 1 then
            Hsync <= '1';
        end if;
        if h_counter = 95 then
            Hsync <= '0';
        end if;

        if v_counter = V_LIMIT - 1 then
            Vsync <= '1';
        end if;
        if v_counter = 1 then
            Vsync <= '0';
        end if;
    end if;
end process;

rgb_proc : process(pixel_clk) is
begin
    if rising_edge(pixel_clk) then
        if (h_counter = H_RES / 2 + H_L_BORDER) or (v_counter = V_RES / 2 + V_T_BORDER) then
            vgaBlue <= "1111";
        else
            vgaBlue <= "0000";
        end if;
    end if;
end process;

end rtl;
