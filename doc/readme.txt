Installation & Running the Simulation
-------------------------------------

1. Create folder LaHowara
2. Copy sources and input folders to this folder
3. Add the path to the xml toolbox (as usually with 'File->Set Path->Add Folder')
4. Start simulation with the following two commands:
	i)  sim = Controller('input/{path-to-config.xml}')  example: sim = Controller('input/square/config.xml')
	ii) simulate(sim);

Rerunning the Simulation:
--------------------------
For a simulation restart execute first command 'clear all'.

Why is this command required at the moment: We are working on loading the infrastructure from a .mat file. However, this is not yet finished.


Reading Online-help:
--------------------
Execute command 'doc LaHowara' and follow the links therein.



2011, A. Horni, L. Montini, R.A. Waraich

