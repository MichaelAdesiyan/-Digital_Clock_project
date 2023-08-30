library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity functs_select_mux is
port( sel:in std_logic_vector(2 downto 0);
		a,b,c,d,e,f:in integer:=0;
		output:out integer
		);
		

end entity functs_select_mux;

architecture clock of functs_select_mux is
	
begin
	process(sel)
	begin
		if sel="111" then
			output<=a;
		elsif sel="110" then
			output<=b;
		elsif sel="100" then
			output<=d;
		elsif sel="100" then
			output<=e;
		else
			output<=f;
		end if;
	end process;
	
end architecture clock;