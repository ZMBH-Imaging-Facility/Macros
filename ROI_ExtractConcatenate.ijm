// November 2015
// ZMBH Imaging Facility
// Holger Lorenz
// Zentrum fuer Molekulare Biologie der Universitaet Heidelberg, Germany

macro "ROI_ExtractConcatenate" {			

Waiting_Time = 50;
Enlarge = 25;
indivChannel = false;

checkImageNumber =true;
while (checkImageNumber) {
	showStatus("Checking open Image(s) ...");
  	 	if (nImages == 1) {
			checkImageNumber = false;
			}	else {		
			waitForUser("- Have only one image/image stack open. \n \n\n- Close any additional images/image stacks. \n \n\n- Click OK when ready to proceed.");
			wait(Waiting_Time);
		  	  		}
	}
// Create Dialog
Dialog.create("ROI_Extract&Concatenate");
Dialog.setInsets(0,20,0);
Dialog.addHelp("http://www.zmbh.uni-heidelberg.de/Central_Services/Imaging_Facility/2D_ImageJ_Macros.html")
//Dialog.setInsets(5,15,0);
//Dialog.addMessage("---------------------------------------");
Dialog.setInsets(0,20,0);
Dialog.addNumber("ROI size? Pixel radius from center position:",Enlarge,0,6,"");
Dialog.setInsets(0,20,0);
items = newArray("Square", "Circular");
Dialog.addRadioButtonGroup("ROI shape:",items,1,2, "Circular");
Dialog.setInsets(0,20,0);
items = newArray("Black", "White (RGB)");
Dialog.addRadioButtonGroup("ROI frame (if ROI shape is circular):",items,1,2, "White (RGB)");
//Dialog.setInsets(0,20,0);
Dialog.addMessage("---------------------------------------");
Dialog.addCheckbox("Individual channel display (only for composite images)?", indivChannel);
Dialog.setInsets(0,20,0);
Dialog.show;

// Read Dialog 

Enlarge = Dialog.getNumber();
ROI_Shape = Dialog.getRadioButton();
ROI_Frame = Dialog.getRadioButton();
indivChannel = Dialog.getCheckbox();

if(is("composite")==false) {
	
FirstImage = getImageID();
run("Select None");

if (roiManager("count")==0) {
		waitForUser("Open an existing ROI set \nor draw ROI into the images \nand add [t] to ROI Manager." );
		}

setBatchMode(true);

run("Duplicate...", "duplicate");
FirstCopy = getImageID();
rename("1stCopy");
run("8-bit");
run("Select All");
run("Set...", "value=0 stack");
run("Set Scale...", "distance=0 known=0");

options = "";
LastROI = roiManager("count");
roiManager("Show None");
wait(Waiting_Time);
setForegroundColor(255, 255, 255);
wait(Waiting_Time);

for (n = 0;n<LastROI;n++) {
	roiManager("Select", n);
	wait(Waiting_Time);
	run("Fill", "slice");
	wait(Waiting_Time);
	run("Make Inverse");
	wait(Waiting_Time);
	run("Set...", "value=0 slice");	
	wait(Waiting_Time);
	run("Select None");
	wait(Waiting_Time);	}

  //input = getImageID();
  n = nSlices();
  for (i=1; i<=n; i++) {
     showProgress(i, n);
     selectImage(FirstCopy);
	wait(Waiting_Time);
     setSlice(i);
	wait(Waiting_Time);
	run("Find Maxima...", "noise=1 output=[Single Points]"+options);
	wait(Waiting_Time);
     if (i==1)
        output = getImageID();
	//wait(Waiting_Time);
    else if ("Single Points"!="Count") {
       run("Select All");
	wait(Waiting_Time);
       run("Copy");
       close();
	wait(Waiting_Time);
       selectImage(output);
	wait(Waiting_Time);
       run("Add Slice");
	wait(Waiting_Time);
       run("Paste");
    }
  }
 run("Select None");

selectImage(output);
rename("Output");


SecondFirstROI = roiManager("count");
//print (SecondFirstROI);

setBatchMode("show");
wait(Waiting_Time);

selectImage(FirstCopy);
close();

wait(Waiting_Time);


if(ROI_Shape=="Square"){
	for (p = 0;p<LastROI;p++) {
	roiManager("Select", p);
	wait(Waiting_Time);
	selectImage(output);
	wait(Waiting_Time);
     setThreshold(1.0000, 255.0000);
		wait(Waiting_Time);
		run("Create Selection");
		wait(Waiting_Time);
		resetThreshold();
	wait(Waiting_Time);
     		run("Enlarge...", "enlarge=Enlarge");
		wait(Waiting_Time);
		run("To Bounding Box");
		wait(Waiting_Time);
		roiManager("Add");
		}
}

if(ROI_Shape=="Circular"){
	for (p = 0;p<LastROI;p++) {
	roiManager("Select", p);
	wait(Waiting_Time);
	selectImage(output);
	wait(Waiting_Time);
     setThreshold(1.0000, 255.0000);
		wait(Waiting_Time);
		run("Create Selection");
		wait(Waiting_Time);
		resetThreshold();
		wait(Waiting_Time);
		run("Enlarge...", "enlarge=Enlarge");
		wait(Waiting_Time);
		roiManager("Add");
		}
}

wait(Waiting_Time);
SecondLastROI = roiManager("count");
//print(SecondLastROI);


wait(Waiting_Time);
selectImage(output);
close();


if(ROI_Shape=="Circular" && ROI_Frame=="White") {
		setBackgroundColor(65535, 65535, 65535);
		}
if(ROI_Shape=="Circular" && ROI_Frame=="Black") {
		run("Colors...", "foreground=black background=black selection=yellow");;
		}

wait(Waiting_Time);	

for (j = SecondFirstROI;j<SecondLastROI;j++) {
		selectImage(FirstImage);
		wait(Waiting_Time);
		roiManager("Select", j);
		wait(Waiting_Time);
		Stack.getPosition(channel, slice, frame);
		xyc= frame;
		wait(Waiting_Time);	
		//print(frame);
		run("Duplicate...", " ");
		wait(Waiting_Time);
		if(ROI_Shape=="Circular") {
			run("Clear Outside", "slice");
			run("Select None");
			}
		wait(Waiting_Time);	
		}

selectImage(FirstImage);
close();

wait(Waiting_Time);
run("Concatenate...", "all_open title=SubframeStack");

wait(Waiting_Time);

setBatchMode(false);

}

else {

if(is("composite")==true) {

//run("Stack to Hyperstack...", "display=Composite");
// Stack dimensions:
	Stack.getDimensions(Width,Height,Channels,Slices,Frames);
	 

	if (roiManager("count")==0) {
		waitForUser("Draw ROIs into image\nand add [t] to ROI Manager,\nor open an existing ROI set." );
		}

FirstImage = getImageID();
run("Select None");

setBatchMode(true);

run("Duplicate...", "duplicate");
//run("Duplicate...", "duplicate channels=1");
FirstCopy = getImageID();
rename("1stCopy");
run("8-bit");
run("Select All");
run("Set...", "value=0 stack");
run("Set Scale...", "distance=0 known=0");

options = "";
LastROI = roiManager("count");
//print("LastROI= ", LastROI);
roiManager("Show None");
wait(Waiting_Time);
setForegroundColor(255, 255, 255);
wait(Waiting_Time);

for (n = 0;n<LastROI;n++) {
	roiManager("Select", n);
	wait(Waiting_Time);
	run("Fill", "slice");
	wait(Waiting_Time);
	run("Make Inverse");
	wait(Waiting_Time);
	run("Set...", "value=0 slice");	
	wait(Waiting_Time);
	run("Select None");
	wait(Waiting_Time);	
	}


  //input = getImageID();
  n = nSlices();
	//print("nSlice= ", n);
  for (i=1; i<=n; i++) {
     showProgress(i, n);
     selectImage(FirstCopy);
	wait(Waiting_Time);
     setSlice(i);
	wait(Waiting_Time);
	run("Find Maxima...", "noise=1 output=[Single Points]"+options);
	wait(Waiting_Time);
     if (i==1)
        output = getImageID();
	//wait(Waiting_Time);
    else if ("Single Points"!="Count") {
       run("Select All");
	wait(Waiting_Time);
       run("Copy");
       close();
	wait(Waiting_Time);
       selectImage(output);
	wait(Waiting_Time);
       run("Add Slice");
	wait(Waiting_Time);
       run("Paste");
    }
  }


 run("Select None");

selectImage(output);
rename("Output");

run("Stack to Hyperstack...", "order=xyczt(default) channels=Channels slices=Slices frames=Frames display=Color");
output = getImageID();

SecondFirstROI = roiManager("count");
//print ("SecondFirstROI= ", SecondFirstROI);

setBatchMode("show");
wait(Waiting_Time);

selectImage(FirstCopy);
close();

wait(Waiting_Time);

if(ROI_Shape=="Square"){
	for (p = 0;p<LastROI;p++) {
		selectImage(output);
		wait(Waiting_Time);
		roiManager("Select", p);
		wait(Waiting_Time);
     		setThreshold(1.0000, 255.0000);
		wait(Waiting_Time);
		run("Create Selection");
		wait(Waiting_Time);
		resetThreshold();
		wait(Waiting_Time);
     		run("Enlarge...", "enlarge=Enlarge");
		wait(Waiting_Time);
		run("To Bounding Box");
		wait(Waiting_Time);
		roiManager("Add");
		}
	}

if(ROI_Shape=="Circular"){
		for (p = 0;p<LastROI;p++) {
		selectImage(output);
		wait(Waiting_Time);
		roiManager("Select", p);
		wait(Waiting_Time);
     		setThreshold(1.0000, 255.0000);
		wait(Waiting_Time);
		run("Create Selection");
		wait(Waiting_Time);
		resetThreshold();
		wait(Waiting_Time);
		//print("Now Enlarge!");
		run("Enlarge...", "enlarge=Enlarge");
		wait(Waiting_Time);
		roiManager("Add");
		}
	}

wait(Waiting_Time);
SecondLastROI = roiManager("count");
//print("SecondLastROI= ", SecondLastROI);

wait(Waiting_Time);
selectImage(output);
close();


if(ROI_Shape=="Circular" && ROI_Frame=="White (RGB)") {
		run("Colors...", "foreground=black background=white selection=yellow");		}
if(ROI_Shape=="Circular" && ROI_Frame=="Black") {
		run("Colors...", "foreground=black background=black selection=yellow");;
		}

wait(Waiting_Time);	

for (j = SecondFirstROI;j<SecondLastROI;j++) {
		selectImage(FirstImage);
		wait(Waiting_Time);
		roiManager("Select", j);
		wait(Waiting_Time);	
		Stack.getPosition(channel, slice, frame);
		xyc= frame;
		zzz=slice;
		qqq=channel;
		wait(Waiting_Time);	
		//print(frame);
		wait(Waiting_Time);	
		//run("Duplicate...", "duplicate slices=zzz frames=xyc");
		if (indivChannel == true) {
			run("Duplicate...", "duplicate channels=qqq slices=zzz frames=xyc");
			run("RGB Color");
			} else {
				run("Duplicate...", "duplicate slices=zzz frames=xyc");
				}
		wait(Waiting_Time);	
		if(ROI_Shape=="Circular") {
			run("Clear Outside", "stack");	
			run("Select None");	
			}	
		wait(Waiting_Time);	
		}

selectImage(FirstImage);
close();

wait(Waiting_Time);

run("Concatenate...", "all_open title=SubframeStack");

// if (indivChannel == true) {
//		run("Grays");
//		}
if (indivChannel == false) {
		run("Make Composite");
		}

wait(Waiting_Time);
setBatchMode(false);


}

}

}
