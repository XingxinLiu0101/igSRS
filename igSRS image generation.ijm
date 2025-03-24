//	igSRS generation with 2 SRS and 1 FIS images
	identifier1 = "Species1.tif";	//Species1 source image name
	Color1 = "Green";		//Species1 will be colored as Color1
	identifier2 = "Species2.tif";   //Species2 source image name
	Color2 = "Magenta";		//Species2 will be colored as Color2
	identifier3 = "FIS.tif";
	BlurRange = 0.5;

//	Select the target images
	n = nImages;
	setBatchMode(true);
	for (i=1; i<=n; i++) {
		selectImage(i);
		imageTitle = getTitle();
		imageId = getImageID();
		if (matches(imageTitle, "(.*)"+identifier1+"(.*)")) {
			channel1title = getTitle();			
		}
		if (matches(imageTitle, "(.*)"+identifier2+"(.*)")) {
			channel2title = getTitle();			
		}
		if (matches(imageTitle, "(.*)"+identifier3+"(.*)")) {
			FIStitle = getTitle();			
		}
	}
	setBatchMode(false);

//
	selectWindow(FIStitle);			
	resetMinAndMax();
	c3=substring(FIStitle,0,lengthOf(FIStitle)-4);
	run("Duplicate...", "title="+c3+"copy");
	FIStitle = c3+"copy";
	rescale();
	selectWindow(channel1title);	 	
	resetMinAndMax();
	c1=substring(channel1title,0,lengthOf(channel1title)-4);
	run("Duplicate...", "title="+c1+"copy");
	channel1title = c1+"copy";
	cutSubMedian(channel1title);
	Blurdenoise(BlurRange);
	min1 = getValue("Min");
	max1 = getValue("Max");
	run("Subtract...", "value="+min1);
	selectWindow(channel2title);
	resetMinAndMax();
	c2=substring(channel2title,0,lengthOf(channel2title)-4);
	run("Duplicate...", "title="+c2+"copy");
	channel2title = c2+"copy";
	cutSubMedian(channel2title);
	Blurdenoise(BlurRange);
	min2 = getValue("Min");
	max2 = getValue("Max");
	run("Subtract...", "value="+min2);

	scale = maxOf(max1-min1, max2-min2);
	selectWindow(channel1title);
	run("Divide...", "value="+scale);
	run("Add...", "value=0.001");
	run("Divide...", "value=1.001");
	setMinAndMax("0.001", "1.0");
	selectWindow(channel2title);
	run("Divide...", "value="+scale);
	run("Add...", "value=0.001");
	run("Divide...", "value=1.001");
	setMinAndMax("0.001", "1.0");

	imageCalculator("Add create", channel1title, channel2title);
	rename("sum");
	imageCalculator("Divide create", channel1title,"sum");
	rename("1/sum");
	imageCalculator("Divide create", channel2title,"sum");
	rename("2/sum");

	imageCalculator("Multiply create", FIStitle,"1/sum");
	rename("channel1");
	run(Color1);
	imageCalculator("Multiply create", FIStitle,"2/sum");
	rename("channel2");
	run(Color2);
	selectWindow("channel1");
	min1 = getValue("Min");
	max1 = getValue("Max");
	med1 = getValue("Median");
	selectWindow("channel2");
	min2 = getValue("Min");
	max2 = getValue("Max");
	med2 = getValue("Median");
	scale = maxOf(max1, max2);
	selectWindow("channel1");
	setMinAndMax(med1, scale);
	selectWindow("channel2");
	setMinAndMax(med2, scale);
	run("Merge Channels...", "c1=channel1 c2=channel2 create");
	close(channel1title);close(channel2title);close(FIStitle);
	close("sum");close("1/sum");close("2/sum");
	
/****************************************************************************/
	function rescale() {
		min = getValue("Min");
		max = getValue("Max");
		scale = max-min;
		run("Subtract...", "value="+min);
		run("Multiply...", "value=0.999");
		run("Divide...", "value="+scale);
		run("Add...", "value=0.001");
		resetMinAndMax();
	}
	function cutSubMedian(tit) {
		M=getValue("Median");
		changeValues(-100, M, M);
	}
	function Blurdenoise(BlurRange) {
		if (BlurRange > 0) {
		run("Gaussian Blur...", "sigma="+BlurRange);
		}
	}
