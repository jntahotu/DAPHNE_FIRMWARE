

#create_generated_clock -name local_clk62p5  [get_pins endpoint_inst/mmcm0_inst/CLKOUT0]
#create_generated_clock -name sclk200        [get_pins endpoint_inst/mmcm0_inst/CLKOUT1]
#create_generated_clock -name sclk100        [get_pins endpoint_inst/mmcm0_inst/CLKOUT2]
#create_generated_clock -name mmcm0_clkfbout [get_pins endpoint_inst/mmcm0_inst/CLKFBOUT]

#create_generated_clock -name ep_clk62p5      [get_pins endpoint_inst/pdts_endpoint_inst/pdts_endpoint_inst/rxcdr/mmcm/CLKOUT0]
#create_generated_clock -name clk4x        [get_pins U0/Time_stamp_axi_v1_0_s00_AXI_inst/uut/pdts_endpoint_inst/rxcdr/mmcm/CLKOUT1]
#create_generated_clock -name clk2x        [get_pins U0/Time_stamp_axi_v1_0_s00_AXI_inst/uut/pdts_endpoint_inst/rxcdr/mmcm/CLKOUT2]
#create_generated_clock -name clkfbout     [get_pins endpoint_inst/pdts_endpoint_inst/pdts_endpoint_inst/rxcdr/mmcm/CLKFBOUT] 

#create_generated_clock -name oeiclk [get_pins phy_inst/U0/core_clocking_i/mmcm_adv_inst/CLKOUT0] 
#create_generated_clock -name oeihclk [get_pins phy_inst/U0/core_clocking_i/mmcm_adv_inst/CLKOUT1]
#create_generated_clock -name oei_clkfbout [get_pins phy_inst/U0/core_clocking_i/mmcm_adv_inst/CLKFBOUT]

#create_generated_clock -name daqclk0      [get_pins core_inst/core_mgt4_inst/daq_quad_inst/U0/gt_usrclk_source/txoutclk_mmcm0_i/mmcm_adv_inst/CLKOUT0]
#create_generated_clock -name daqclk1      [get_pins core_inst/core_mgt4_inst/daq_quad_inst/U0/gt_usrclk_source/txoutclk_mmcm0_i/mmcm_adv_inst/CLKOUT1]
#create_generated_clock -name daq_clkfbout [get_pins core_inst/core_mgt4_inst/daq_quad_inst/U0/gt_usrclk_source/txoutclk_mmcm0_i/mmcm_adv_inst/CLKFBOUT]

#create_generated_clock -name fclk0           -master_clock ep_clk62p5 [get_pins endpoint_inst/mmcm1_inst/CLKOUT0]
#create_generated_clock -name mclk0           -master_clock ep_clk62p5 [get_pins endpoint_inst/mmcm1_inst/CLKOUT1]
#create_generated_clock -name mmcm1_clkfbout0 -master_clock ep_clk62p5 [get_pins endpoint_inst/mmcm1_inst/CLKFBOUT]
#create_generated_clock -name fclk1           -master_clock local_clk62p5 [get_pins endpoint_inst/mmcm1_inst/CLKOUT0]
#create_generated_clock -name mclk1           -master_clock local_clk62p5 [get_pins endpoint_inst/mmcm1_inst/CLKOUT1]
#create_generated_clock -name mmcm1_clkfbout1 -master_clock local_clk62p5 [get_pins endpoint_inst/mmcm1_inst/CLKFBOUT]