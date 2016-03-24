
# Pro_Motion_App (obj-C)
iOS application that connects to and interprets data from the Neblina module.

Steps to build Pro_Motion_App project (assumes Xcode 7.2):

Step 1) Create a new folder for the sources and change directory to that

Step 2) git clone https://github.com/Motsai/neblina-ios.git

Step 3) Get Charts dependency:
git clone --depth=50 --branch=v2.1.6 https://github.com/danielgindi/ios-charts.git

Step 4) Get CorePlot dependency:
git clone https://github.com/core-plot/core-plot.git

Step 5) 
Open “neblina-ios==>Pro_Motion_App==>ProMotionApp.xcodeproj.”
In “Pro_Motion_App project settings”->General->”Embedded Binaries” ==> Remove “Charts.framework”
Also remove the (red) references to “Charts.xcodeproj” and “CorePlot-CocoaTouch.xcodeproj” in Pro_Motion_App project (we will add them shortly).

Step 6)
Drag the downloaded “Charts.xcodeproj” (ios-charts/Charts/Charts.xcodeproj) in Pro_Motion_App project.
Drag the downloaded “CorePlot-CocoaTouch.xcodeproj” (core-plot/framework/CorePlot-CocoaTouch.xcodepro) in Pro_Motion_App project.

Step 7) 
Add BalloonMarker.swift  to the “Charts.xcodeproj” (under Classes/Components): from “ios-charts->ChartsDemo->Classes->Components->BalloonMarker.swift”

Step 8)
In “Pro_Motion_App project settings”->General->”Embedded Binaries” ==> Add “Charts.framework” (iOS)

Step 9)
In “Pro_Motion_App project settings”->Build Phases->”Target Dependencies”==>Add “CorePlot-CocoaTouch”
In “Pro_Motion_App project settings”->Build Phases->”Link Binary With Libraries”==>Add “libCorePlot-CocoaTouch.a”

Now build Pro_Motion_App.