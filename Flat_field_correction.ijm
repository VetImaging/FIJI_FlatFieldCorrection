/* Macro for applying flat field correction onto bright field images
 * using a blank reference image acquired with the same settings
 * input: series of microscopic images with same setting (tif, jpg, czi) + blank image
 * output: flat field corrected tifs
 * important: Image titles MUST NOT have blanks!!
 * UR / VetImaging / VetCore / Vetmeduni Vienna 2019
 */
 

#@ String (visibility=MESSAGE, value="Choose your files and parameter, Image titles MUST NOT have blanks!") msg
#@ File (label = "Input directory", style = "directory") input_folder
#@ File (label = "Output directory", style = "directory") output_folder
#@ File (label = "Background image", style = style = "open, extensions:tif/tiff/jpg/jpeg/czi") BackgroundImage
#@ String (label = "File suffix input", choices={".jpg",".jpeg",".png",".tif",".TIF",".tiff",".czi"}, style="radioButtonHorizontal") 	suffix_in


open(BackgroundImage);
BackgroundImageTitle = getTitle();
if (suffix_in == ".czi") {
	run("RGB Color");
	selectImage(BackgroundImageTitle);
	run("Close");
	selectImage(BackgroundImageTitle+" (RGB)");
	rename(BackgroundImageTitle);
}

// measure mean intensity of background image and get value + print in log file
run("Select All");
run("Measure");
getStatistics(area, bgMeanValue);
print("Mean value of "+BackgroundImageTitle+": "+bgMeanValue);

selectWindow("Results");
run("Close");

setBatchMode(true);
list = getFileList(input_folder);

for (i=0; i<list.length; i++) {
	if (endsWith(list[i], suffix_in)){
		print("file " + i + ": " + input_folder+"\\"+list[i]);
		open(input_folder+"\\"+list[i]); 

		//get Title
		imageTitle = getTitle();
		run("Calculator Plus", "i1="+imageTitle+" i2="+BackgroundImageTitle+" operation=[Divide: i2 = (i1/i2) x k1 + k2] k1="+bgMeanValue+" k2=0 create");
		selectWindow("Result");
		saveAs(".tif", output_folder+"\\"+imageTitle); // change if imageTitle of corrected images shall be changed
		run("Close");
		selectWindow(BackgroundImageTitle);
		close("\\Others"); // close all images except for background image
	}
}
   
selectWindow(BackgroundImageTitle);
run("Close");

Dialog.create("Macro finished");
Dialog.addMessage("Flat field correction of images in the folder \n"+output_folder+"\nis finished!"); 
Dialog.show();