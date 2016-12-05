// August 2016
// ZMBH Imaging Facility
// Holger Lorenz
// Zentrum fuer Molekulare Biologie der Universitaet Heidelberg, Germany


// This macro opens files from a selected folder plus subfolders.   
// It only opens those files containing a user-defined substring, i.e. a partial name or number.
// Files that either start or end with the substring, or files that have the substring anywhere 
// within its name can specifically be opened.
// If wanted, the opened image files can be concatenated to a stack.


macro "OpenSpecFiles" {		

requires("1.49d");

StringIns="123abc"

// Create Dialog
Dialog.create("OpenSpecFiles");
Dialog.setInsets(0,20,0);
items = newArray("contains...", "starts with...", "ends with...");
Dialog.addRadioButtonGroup("String",items,1,3, "contains...");
Dialog.setInsets(0,20,0);
Dialog.addString(">>>", StringIns)
Dialog.addMessage(" ");
Dialog.setInsets(0,20,0);
Dialog.addCheckbox("Concatenate images?", true);
Dialog.show;


// Read Dialog 
a1 = Dialog.getRadioButton();
concate = Dialog.getCheckbox();
StringIns=Dialog.getString();


//Boolean expressions
if(a1=="contains..."){
		dir = getDirectory("Choose a Directory ");
			listFilesContains(dir);
}

if(a1=="starts with..."){
		dir = getDirectory("Choose a Directory ");
			listFilesStart(dir);
}

if(a1=="ends with..."){
			dir = getDirectory("Choose a Directory ");
			listFilesEnds(dir);
}


//Functions
function listFilesContains(dir) {
	list = getFileList(dir);
		for (i=0; i<list.length; i++) {
			if (endsWith(list[i], "/")){
           	listFilesContains(""+dir+list[i]);
			}
				if (indexOf(list[i], StringIns)>=0) {
				open(dir + list[i]);
				}
     	}
}

function listFilesStart(dir) {
	list = getFileList(dir);
		 for (i=0; i<list.length; i++) {
			if (endsWith(list[i], "/")){
           	listFilesStart(""+dir+list[i]);
			}
				if (startsWith(list[i], StringIns)){
				open(dir + list[i]);
				}
     		}
  		}

function listFilesEnds(dir) {
	list = getFileList(dir);
		for (i=0; i<list.length; i++) {
			if (endsWith(list[i], "/")){
			listFilesEnds(""+dir+list[i]);
			}
				if (endsWith(list[i], StringIns)) {
				open(dir + list[i]);
				}
     		}
  		}


//Concatenation (stack making)
if (concate==true) { 
		run("Concatenate...", "all_open title=[Concatenated Stacks]");
	}

}
