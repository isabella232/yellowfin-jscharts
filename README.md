# yellowfin-jscharts
Custom Javascript Charts you can use directly in YellowfinBI starting from 7.3+ and onwards

## setup
1. Copy the whole `lib` folder into `/appserver/webapps/ROOT` inside your Yellowfin installation.
2. Copy the source code from `examples` into the yellowfin frontend when creating a report. Choose *Javascript Chart* as chart type and *Javascript* as inside the *Select Chart* overlay. The copied source code should be pasted in the *Javascript* tab.
3. Replace the metrics and dimensions in the example source code marked with *//CONFIGURE:* with the ones you want to show. This metrics and dimensions need to be delivered in the *Data* view. Watch the comments inside source code of the specific example for further instructions.
