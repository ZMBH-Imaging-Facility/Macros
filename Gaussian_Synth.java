// Program: Gaussian_Synth.java
// Version: 1
// Programming language: Java (ImageJ Plugin)
// Description: Synthesizes a spot with Gaussian intensity on an opened image. Four parameters of Center (X and Y), width, and the intensity of the Gaussian profile can be adjusted interactively. The synthesized image can be used again to synthesize other spots (by preserving previous ones). The starting point for this Java program was the program Cross_Fader.java, written by Michael Schmid. 

import ij.*;
import ij.process.*;
import ij.plugin.filter.ExtendedPlugInFilter;
import ij.plugin.filter.PlugInFilterRunner;
import ij.gui.DialogListener;
import ij.gui.GenericDialog;
import java.awt.*;

public class Gaussian_Synth implements ExtendedPlugInFilter, DialogListener {
   private static int FLAGS = DOES_8G | DOES_16 | KEEP_PREVIEW;

   private double fwhmWidth;      //Width of the to-be-synthesized Gaussian intensity
   private double percentageAmplitude;	//Amplitude of the to-be-synthesized Gaussian intensity
   private double percentageX;			//X coordinate of the center of the to-be-synthesized Gaussian intensity
   private double percentageY;			//Y coordinate of the center of the to-be-synthesized Gaussian intensity
   private ImagePlus imp;
   
   public int setup (String arg, ImagePlus imp) {
       return FLAGS;
   }

   public int showDialog (ImagePlus imp, String command, PlugInFilterRunner pfr) {
       int width;
       int height;

       if (imp.getNSlices() > 1) {
           IJ.error("A single image (not a stack) is expected.");
           return DONE;
       }
       if (imp.getNChannels() > 1) {
           IJ.error("A single-channel image is expected.");
           return DONE;
       }
       if (imp.getBitDepth() > 16) {
           IJ.error("Only 8- and 16-bit gray-scale images are allowed.");
           return DONE;
       }

       this.imp = imp;
       width = imp.getWidth();
       height = imp.getHeight();
       GenericDialog gd = new GenericDialog(command+"...");
       gd.addSlider("Gaussian Width (FWHM in Pixels)", 0.1, 100, 3.0);
       gd.addSlider("Gaussian Amplitude", 0, 100, 80.0);
       gd.addSlider("X of Center", 0, 100, 50.0);
       gd.addSlider("Y of Center", 0, 100, 50.0);
       gd.addPreviewCheckbox(pfr);
       gd.addDialogListener(this);
       gd.showDialog();
       if (gd.wasCanceled()) {
           return DONE;
       }
       return FLAGS;
   }

   public boolean dialogItemChanged (GenericDialog gd, AWTEvent e) {
       fwhmWidth = gd.getNextNumber();
       percentageAmplitude = gd.getNextNumber();
       percentageX = gd.getNextNumber();
       percentageY = gd.getNextNumber();
       return !gd.invalidNumber() && fwhmWidth>=0 && fwhmWidth <=100;
       //One could also check other (percentage...) variables against allowed limits here.
   }

   public void run (ImageProcessor ip) {
       synthGauss(ip);
   }

   private void synthGauss(ImageProcessor ip) {
       int xCntr;
       int yCntr;
       double pixelValue;

       int width = ip.getWidth();
       int height = ip.getHeight();
       double gWidth2 = sq(fwhmWidth) / (4 * Math.log(2));	//gWidth2 = 2 * Sigma^2, where Sigma = w_FWHM / sqrt(8 * ln(2))
       double xOffset = (percentageX / 50 - 0.5) * width;
       double yOffset = (percentageY / 50 - 0.5) * height;
       double maxI = (imp.getBitDepth() == 8) ? 255.0:65535.0;
       double Amplitude = maxI * (percentageAmplitude / 100);

       for (yCntr = 0; yCntr < height; yCntr++) {
	       for (xCntr = 0; xCntr < width; xCntr++) {
	       	 pixelValue = Amplitude * Math.exp(- (
	       	 					sq((double) xCntr - xOffset) / gWidth2 + sq((double) yCntr - yOffset) / gWidth2
	       	 				));
	       	 ip.putPixel(xCntr, yCntr, ip.get(xCntr, yCntr) +(int) pixelValue);
	       }
       }
       imp.setDefault16bitRange((maxI == 255.0) ? 8:0);
   }   

   private double sq(double x) {
   	 return x * x;
   }

   public void setNPasses (int nPasses) {
   }
}
