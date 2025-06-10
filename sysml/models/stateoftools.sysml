package StateOfSysmlV2Tools {
	doc
	/*
	* Model of current available SysMLv2 Tools
	* Primarily focused on open source or publicly previewed tools.
	*/

	public import PortDefinitions::*;
	public import ItemDefinitions::*;

	package ItemDefinitions {
		item def Image;
		item def DynamicVizualization :> Image;
		item def TreeView :> Image;
		item def InterconnectionView :> Image;
		item def StateView :> Image;
		item def ActionView :> Image;
		item def SequenceView :> Image;
		item def MixedView :> Image;

		item def ApiCommand;
		item def JavaCommand :> ApiCommand;
		item def UnknownApiCommand :> ApiCommand;
		item def SysmlV2ApiCommand :> ApiCommand;

		item def File;
		item def SysmlV2file :> File;
		item def IncrementalSysmlV2file :> SysmlV2file;
		item def ExportSysmlV2file :> SysmlV2file;
		item def JsonFile :> File;
	}
	
	package Parts {
		part LocalFileSystem{
			port fileOut:~FileInputSysml;
			port fileIn: FileInputSysml;
		}
		part GraphViz{
			port vizCmdPort:JavaSysmlV2RefImplCmd;
			port vizOutPort:~VizualizationIn;
		}
		package Tools {
			part Eclipse{
				/*Eclipse with SysML v2 Plugin
				ref: https://github.com/Systems-Modeling/SysML-v2-Release/tree/master/install/eclipse
				*/
				port fileIn: FileInputSysml;
				port fileOut: ~FileInputSysml;
				port cmdOut;
			}
			part SysIDE_Editor{
				/*SysIDE Editor free vscode extension
				ref: https://marketplace.visualstudio.com/items?itemName=sensmetry.sysml-2ls
				*/
				port fileIn:FileInputSysml;
				port fileOut:~FileInputSysml;
				port cmdOut:~UnknownApiInput;
			}
			part SysIDE_Modeler {
				/*SysIDE Modeler premium modeling environment
				ref: https://sensmetry.com/syside/
				*/
				port cmdIn: UnknownApiInput;
				port cmdOut: ~UnknownApiInput;
			}
			part TomSawyerViewer{
				/*Tom Sawyer SysML v2 Viewer
				ref: https://www.tomsawyer.com/sysml-v2-viewer
				*/
				port vizOut:DynamicVizOut;
				port apiIn: ~SysmlV2RestAPIOut;
			}
			part TomSawyerSysIDE_Embedded{
				/*Tom Sawyer SysML v2 Viewer embedded with SysID_Modeler
				ref: https://sensmetry.com/syside/
				*/
				port cmdIn:UnknownApiInput;
				port vizOut:DynamicVizOut;
			}
			part JupyterKernelSysml{
				/*Jupyter notebook SysML v2 support
				ref: https://github.com/Systems-Modeling/SysML-v2-Release/tree/master/install/jupyter
				example server: https://www.sysmlv2lab.com/lab?
				*/
				port fileIn:FileInputSysml;
				port vizCmdPort:~JavaSysmlV2RefImplCmd;
				port apiOut:SysmlV2RestAPIOut;
			}
			part SysMlV2API_Server_Intercax{
				/*Exampe SysML v2 API Server
				ref: http://sysml2.intercax.com:9000
				*/
				port apiIn: ~SysmlV2RestAPIOut;
				port apiOut: SysmlV2RestAPIOut;
			}
			part SysON{
				/*SysON open source web based SysML v2 application
				ref: https://github.com/eclipse-syson/syson
				ref: https://mbse-syson.org/
				*/
				port fileImport: FileInputSysml;
				port fileExport: ~FileInputSysml;
				port database;
			}
			part PythonSysmlV2Cookbook{
				/*Python SysML v2 API Cookbook
				ref: https://github.com/Systems-Modeling/SysML-v2-API-Cookbook
				 */
				port apiIn: ~SysmlV2RestAPIOut;
				port apiOut: SysmlV2RestAPIOut;
			}
			package connections {
				connect JupyterKernelSysml.vizCmdPort to GraphViz.vizCmdPort;
				connect LocalFileSystem.fileOut to JupyterKernelSysml.fileIn;
				connect LocalFileSystem.fileOut to SysIDE_Editor.fileIn;
				comment about JupyterKernelSysml
				/* Are there any actual Jupyter save to SysML other than Copy & Paste? If so:
				* connect JupyterKernelSysml.fileOut to LocalFileSystem.fileIn;
				*/
				interface sipFileConnect connect SysIDE_Editor.fileOut to LocalFileSystem.fileIn {
					flow sipSysmlFlow of IncrementalSysmlV2file
						from SysIDE_Editor.fileOut
						to LocalFileSystem.fileIn;				
				}
				comment about sipFileConnect::sipSysmlFlow, sipFileConnect
				/*The above connect SysIDEParser.fileOut to LocalFileSystem.fileIn
				is, I believe, redundant with the more specific FlowConnectionUsage
				However, the SysIDE Pro v0.5.2 Tom Sawyer visualization isn't rendering
				the flow connection*/		

				connect SysIDE_Editor.cmdOut to SysIDE_Modeler.cmdIn;
				connect SysIDE_Modeler.cmdOut to TomSawyerSysIDE_Embedded.cmdIn;
				connect JupyterKernelSysml.apiOut to SysMlV2API_Server_Intercax.apiIn;
				connect SysMlV2API_Server_Intercax.apiOut to TomSawyerViewer.apiIn;
				connect PythonSysmlV2Cookbook.apiOut to SysMlV2API_Server_Intercax.apiIn;
				connect SysMlV2API_Server_Intercax.apiOut to PythonSysmlV2Cookbook.apiIn;
			}
		}
	}

	package PortDefinitions {
		port def JavaSysmlV2RefImplCmd {
			in item JavaCommand;
		}
		port def VizualizationIn {
			in item Image;
		}
		port def DynamicVizOut {
			out item DynamicVizualization;
		}

		port def GenericFileInput {
			in item File;
		}
		port def FileInputSysml :> GenericFileInput {
			in item SysmlV2file redefines File;
		}
		port def FileInputJson :> GenericFileInput {
			in item JsonFile redefines File;
		}
		
		port def UnknownApiInput {
			in item UnknownApiCommand;
		}
		port def SysmlV2RestAPIOut {
			out item SysmlV2ApiCommand;
		}
	}
}