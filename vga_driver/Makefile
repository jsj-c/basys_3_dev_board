

default: bitstream

bitstream:
	vivado -mode batch -source scripts/build_bitstream.tcl -nojournal -nolog

flash:
	vivado -mode batch -source scripts/flash_bitstream.tcl -nojournal -nolog

clean:
	rm -rf build/
	rm -rf .Xil/
	rm -f clockInfo.txt