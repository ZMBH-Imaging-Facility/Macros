// September 2015
// ZMBH Imaging Facility
// Holger Lorenz
// Zentrum fuer Molekulare Biologie der Universitaet Heidelberg, Germany

macro "Nuclei_PeripheryMeasure" {			
	
	
Waiting_Time = 50;

checkImageNumber =true;
while (checkImageNumber) {
	showStatus("Checking open Image(s) ...");
  	 	if (nImages == 1) {
			checkImageNumber = false;
			}	else {		
			waitForUser("- Have only one 2-CHANNEL IMAGE/IMAGE STACK open. \n \n\n- Close any additional images/image stacks. \n \n\n- Click OK when ready for the analysis.");
			wait(Waiting_Time);
		  	  		}
		}
  	
checkImage=true;
while (checkImage) {
	Stack.getDimensions(width, height, channels, slices, frames);
	if(nImages == 1 && channels==2) {
		checkImage=false;
		}	else {
		waitForUser("Only one 2-CHANNEL IMAGE/IMAGE STACK!");
			wait(Waiting_Time);
		  	  		}
}

// Type of desired operation
Find_nuclei = true; 				// Program to determine the nuclei from one slice
Evaluate_nuclei = true; 			// Program to evaluate the nuclei in each slice


// Surrounding analysis
Surrounding_Distance = 5;
Surrounding_Threshold = 200;
Surrounding_Amount = 50;

// Nuclei detection
Subtract_Background = false; 		// Subtract background from ROI in each slice
Maximum_Nuclei_Radius = 50; 	// in pixels
Minimum_Nuclei_Size = 400; 			// in pixels
Maximum_Nuclei_Size = 3500; 		// in pixels
Minimum_Circularity = 0.10; 		
Maximum_Circularity = 1.00;
Clear_ROIManager = true; 			// clear Roi Manager

requires("1.49d");

run("Options...", "iterations=1 count=1 black");

// Create Dialog
Dialog.create("Nuclei_PeripheryMeasure");
Dialog.setInsets(0,20,0);
Dialog.addCheckbox("Show macro description in ImageJ?", false);
Dialog.setInsets(0,20,0);
Dialog.addCheckbox("Show log window?", true);
Dialog.addHelp("http://www.zmbh.uni-heidelberg.de/Central_Services/Imaging_Facility/2D_ImageJ_Macros.html")
Dialog.setInsets(5,15,0);
Dialog.setInsets(0,10,0);
Dialog.addMessage("-----------------------------------------------------------\nNUCLEI DETECTION");
Dialog.setInsets(0,20,0);
Dialog.addCheckbox("Clear old ROI Manager entries?",Clear_ROIManager);
Dialog.setInsets(0,10,0);
Dialog.addMessage("-----------------------------------------------------------\nNUCLEI SIZE & SHAPE DISCRIMINATION");
Dialog.setInsets(0,20,0);
Dialog.addNumber("Minimum nuclei size (pixels):",Minimum_Nuclei_Size,0,6,"");
Dialog.setInsets(0,20,0);
Dialog.addNumber("Maximum nuclei size (pixels):",Maximum_Nuclei_Size,0,6,"");
Dialog.setInsets(0,20,0);
Dialog.addNumber("Minimum nuclei circularity:",Minimum_Circularity);
Dialog.setInsets(0,20,0);
Dialog.addNumber("Maximum nuclei circularity:",Maximum_Circularity);
Dialog.setInsets(0,10,0);
Dialog.addMessage("-----------------------------------------------------------\nPERIPHERY ANALYSIS");
Dialog.setInsets(0,20,0);
Dialog.addNumber("Surrounding area (dilations):",Surrounding_Distance,0,6,"");
Dialog.setInsets(0,20,0);
Dialog.addNumber("Intensity threshold for analysis:",Surrounding_Threshold);
Dialog.setInsets(0,20,0);
Dialog.addNumber("Minimal number of pixels above threshold:",Surrounding_Amount,0,6,"");

Dialog.show;

// Read Dialog 
descr = Dialog.getCheckbox();
logw = Dialog.getCheckbox();
Minimum_Nuclei_Size = Dialog.getNumber();
Maximum_Nuclei_Size = Dialog.getNumber();
Minimum_Circularity = Dialog.getNumber();
Maximum_Circularity = Dialog.getNumber();
Clear_ROIManager = Dialog.getCheckbox();

Surrounding_Distance = Dialog.getNumber();
Surrounding_Threshold = Dialog.getNumber();
Surrounding_Amount = Dialog.getNumber();

// Rounding and checking numerical values
Surrounding_Distance = abs(round(Surrounding_Distance));
Surrounding_Amount = abs(round(Surrounding_Amount));


Minimum_Nuclei_Size = abs(Minimum_Nuclei_Size);
Maximum_Nuclei_Size = abs(Maximum_Nuclei_Size);
Minimum_Circularity = abs(Minimum_Circularity);
Maximum_Circularity = abs(Maximum_Circularity);
Infinity = 1.0/0.0;


if (descr==true) { 
		showMessage("Nuclei_PeripheryMeasure Info", "Description:\nThe ImageJ macro Nuclei_PeripheryMeasure is used to count the \nnumber of cells with a cytosolic signal above a user-defined threshold \nwithin a cell population. As output, the number of criteria-matching \ncell counts with respect to the total number of cells is provided. \nThe macro works on images or image stacks with two channels. \nIn short, the macro takes the nuclear signal (e.g. DAPI/Hoechst, \nNucRed Live 647,..) in one channel as reference for individual cells. \nSegmentation of nuclei is done by intensity thresholding. The \ncorresponding nuclear areas are registered and used to create binary \nimages as masks. In order to measure the cytosolic signal of the \nsecond channel (GFPs, beta-gal,..), dilations are performed on the binary \nimages in a user-defined manner to take different cell shapes into \nconsideration. The resulting mask images with intensity values 0 (background) \nand 1 (foreground) are multiplied with the images of the second channel \nto select the areas for measurement. \nFor the analysis, the user can specify both a general signal intensity \nthreshold and a minimal number of pixels required above that threshold \nfor positive counts.\nAlthough intended for nuclei peripheries, the macro can, of course, \nbe used for any object's periphery measurement. \nWritten and tested with ImageJ 1.50b on a PC (64bit, Windows 7) and Mac OS X.\n \nZMBH Imaging Facility_HL \nSeptember 2015");
	}
	
if(logw==true) {
	print (" ");
	print ("Minimum nuclei size (pixels): ", Minimum_Nuclei_Size);
	print ("Maximum nuclei size (pixels): ", Maximum_Nuclei_Size);
	print ("Minimum nuclei circularity: ", Minimum_Circularity);
	print ("Maximum nuclei circularity: ", Maximum_Circularity);
	print ("Surrounding area (dilations): ", Surrounding_Distance);
	print ("Intensity threshold for analysis: ", Surrounding_Threshold);
	print ("Minimal number of pixels above threshold: ", Surrounding_Amount);
	print (" ");
	}


	// Stack dimensions:
	Stack.getDimensions(Width,Height,Channels,Slices,Frames);
	if(logw==true){
	print("Width, Height, Channels, Slices, Frames:");
	print(Width,Height,Channels,Slices,Frames);
	}
  	a=Slices;
  	b=Frames;
  
	if ((Slices > 1)  && (Frames == 1)) {
	if(logw==true) {
	print ("*Action* Re-order Hyperstack");
	}
	run("Stack to Hyperstack...", "order=xyctz channels=2 slices=b frames=a display=Color");
	//run("Make Composite");
	Stack.getDimensions(Width,Height,Channels,Slices,Frames);
	if(logw==true){
	print("New Hyperstack order:");
	print(Width,Height,Channels,Slices,Frames);
	print(" ");
	}
	ImReg = getImageID();
	} else {
	ImReg = getImageID();
	if(logw==true){
	print(" ");
	}
	}

run("Select None");

// NUCLEI DETECTION

// Statistical counts
NucleiCount = newArray(Frames);
OutsideInfoCount = newArray(Frames);
Array.fill(NucleiCount,0);
Array.fill(OutsideInfoCount,0);

	wait(Waiting_Time);
	waitForUser("Please, select the channel with the nuclei...");
	Stack.getPosition(Nuclei_Channel,sl,fr);
	// Determination of the surrounding signal channel;
	wait(Waiting_Time);
	waitForUser("Please, select the channel with the periphery to analyze...");
	Stack.getPosition(Surrounding_Channel,sl2,fr2);
	// Create output stack
	run("Duplicate...", "duplicate");
	rename("Output Stack");
	run("Split Channels");
	run("Duplicate...", "duplicate");
	rename("C3-");
	makeRectangle(0,0,Width,Height);

run("Set...", "value=0 stack");	
	run("Merge Channels...", "c1=[C1-Output Stack] c2=[C2-Output Stack] c3=[C3-] create");
	

selectWindow("Output Stack");
rename("Output StackColor");
	Stack.setDisplayMode("color");	

ImOut = getImageID();
	// Extract nuclei stack 	
	selectImage(ImReg);
	Stack.setDisplayMode("color");
	run("Duplicate...", "duplicate channels="+Nuclei_Channel+" slices="+sl);

	ImNuclei = getImageID();
	
	// Clear Roi Manager
	if (Clear_ROIManager) {
		if (roiManager("count")>0) {
			roiManager("Deselect");
			roiManager("Delete");
		}
	}
	FirstROI = roiManager("count");	


// Automatic Threshold
	selectImage(ImNuclei);
	setAutoThreshold("Default dark stack");
	getThreshold(LowTh,UpTh);
//setThreshold(LowTh,UpTh,"over/under");
	setThreshold(35, 255);
	wait(Waiting_Time);	
	waitForUser("Please check the Threshold to select the \nnuclei and adjust it manually if necessary.\n \n(Go Image>Adjust>Threshold to adjust, \nbut do not click Threshold *Apply*.)");
	

// Detection of nuclei
	run("Analyze Particles...", "size="+Minimum_Nuclei_Size+"-"+Maximum_Nuclei_Size+
		" pixel circularity="+Minimum_Circularity+"-"+Maximum_Circularity+" show=Nothing exclude include add stack");
	
	LastROI = roiManager("count");
	roiManager("Show None");

// Create two empty auxiliary image
	selectImage(ImNuclei);
	resetThreshold();
	run("Duplicate...", " ");
	
	ImAux = getImageID();
	run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");	
	newImage("BinaryNucleous", "8-bit black", Width, Height, 1);
	ImBinary = getImageID();	


// Individual Nuclei analysis
	for (n = FirstROI;n<LastROI;n++) {
		showProgress((n-FirstROI)/(LastROI-FirstROI));
wait(Waiting_Time);
		selectImage(ImNuclei);
wait(Waiting_Time);
		roiManager("Select", n);
wait(Waiting_Time);
		Stack.getPosition(ch,sl,fr);		
		// Clear binary images
		selectImage(ImBinary);
wait(Waiting_Time);

//setOption("BlackBackground", true);
//run("Convert to Mask", "method=Default background=Dark black");

		makeRectangle(0,0,Width,Height);
		//run("Select All");
		run("Set...", "value=0");
		wait(Waiting_Time);
		// Create binary nucleous
		roiManager("Select", n);
wait(Waiting_Time);
		run("Set...", "value=255");
		run("Select None");
wait(Waiting_Time);		
		for (k=0;k<Surrounding_Distance;k++) {
			run("Dilate");
	wait(1);
	}
		roiManager("Select", n);
wait(Waiting_Time);
		run("Set...", "value=0");
		run("Select None");		
	wait(1);

	run("Divide...", "value=255");	
		// Copy nucleus to auxiliary image
		makeRectangle(0,0,Width,Height);	
wait(Waiting_Time);	
		run("Copy");

		selectImage(ImAux);
wait(Waiting_Time);
		makeRectangle(0,0,Width,Height);
		run("Paste");				
	// Multiply by channel 2
		selectImage(ImReg);
wait(Waiting_Time);
		Stack.setPosition(Surrounding_Channel,sl,fr);
		imageCalculator("Multiply",ImAux,ImReg);
		wait(Waiting_Time);
		selectImage(ImAux);
wait(Waiting_Time);


// Channel analysis
		setThreshold(Surrounding_Threshold,Infinity,"over/under");
		run("Create Selection");
		getRawStatistics(Area);
		if (Area == (Height*Width)) {
			Area = 0;
		}
	 	if(logw==true){
		print("Periphery area", n+1, " above threshold: ", Area, " pixels");
		//print(Area);
		}
	 
	
		NucleiCount[fr-1] = NucleiCount[fr-1]+1;
		
		if (Area>Surrounding_Amount) {
			OutsideInfoCount[fr-1] = OutsideInfoCount[fr-1]+1;
			wait(Waiting_Time);
		}
}
//end of loop


// Closing auxiliary images
	selectImage(ImNuclei);
	close();
	selectImage(ImAux);
	close();
	selectImage(ImBinary);
	close();
	selectWindow("Output StackColor");
	close("Output StackColor");
	while(isOpen("Output StackColor")) {
	}
	wait(1);

	selectImage(ImReg);
	resetThreshold;
	

// Creation of Output Table
	Results_Title = "Result(s)";
	RT = "["+Results_Title+"]";
	if (!isOpen(Results_Title)) {
		run("New... ","name="+RT+" type=Table");
		Headings = "Stack image\tNuclei\tOutside Signal";
		print(RT,"\\Headings:"+Headings);
	}
	// Filling the output table
	for (n = 0;n<Frames;n++) {
		TableRow= ""+n+"\t"+NucleiCount[n]+"\t"+OutsideInfoCount[n]+"\n";
		print(RT,TableRow);	
	}
	selectImage(ImReg);
	run("Select None");
	Stack.setDisplayMode("composite");

}
  



