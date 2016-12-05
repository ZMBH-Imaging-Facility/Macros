// June 2016
// ZMBH Imaging Facility
// Holger Lorenz
// Zentrum fuer Molekulare Biologie der Universitaet Heidelberg, Germany


//This macro splits an image into user-defined smaller-size images  
//and concatenates them into a stack.
//It works with 8-, 16-, 32-bit, RGB and composite images.
//If concatenation ("stack-making") is NOT needed, just comment out(//) setBatchMode(true) 
//and run("Concatenate...", "all_open title=[title] open")
//in order to get all images tiled up.


macro "SplitImage_andConcatenate" {			
	setBatchMode(true);
	d = getNumber("Divided by 'number' in X and Y?", 3); 
	id = getImageID(); 
	title = getTitle(); 
	getLocationAndSize(locX, locY, sizeW, sizeH); 
	width = getWidth(); 
	height = getHeight(); 
	tileWidth = width/d; 
	tileHeight = height/d; 
		for (y = 0; y < d; y++) { 
			offsetY = y * height/d; 
 				for (x = 0; x <d; x++) { 
					offsetX = x * width/d; 
			selectImage(id); 
 			call("ij.gui.ImageWindow.setNextLocation", locX + offsetX, locY + offsetY); 
			tileTitle = title + " [" + x + "," + y + "]"; 
			run("Duplicate...", "duplicate");
			makeRectangle(offsetX, offsetY, tileWidth, tileHeight); 
			run("Crop"); 
				} 
		} 
	selectImage(id); 
	close(); 
	id = getImageID(); 
	title = getTitle(); 
	run("Concatenate...", "all_open title=[title] open");
	setBatchMode("exit and display");
}
