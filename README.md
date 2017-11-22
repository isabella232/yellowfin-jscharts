# yellowfin-jscharts
Custom Javascript Charts you can use directly in YellowfinBI starting from 7.3+ and onwards

## setup
1. Copy the whole `lib` folder into `/appserver/webapps/ROOT` inside your Yellowfin installation.
2. Copy the source code from `examples` into the yellowfin frontend when creating a report. Got to the *Charts* tab and choose *Javascript Chart* as chart type and *Javascript* inside the *Select Chart* overlay. The copied source code should be pasted in the *Javascript* tab.
3. Replace the metrics and dimensions in the example source code and follow the instructions marked with *//CONFIGURE:*. You probably need to adjust settings in you *Data* view.
