//generateChart is a required function which will be called to generate your Javascript chart
generateChart = function(options) {

   // This will trigger a breakpoint in your browser debugger so you can debug your javascript
   // debugger;

   // This is the div you draw your chart into
   var $chartDrawDiv = $(options.divSelector);

   // To stop scrollbars in any portlets regardless of your javascript, use this css class
   $chartDrawDiv.addClass('jsChartNoOverflow');

   // This gets the height and width from the dataset. Use these when creating your chart so that
   // it will fit the dashboard, canvas and storyboard correctly
   var height = options.dataset.chart_information.height;
   var width = options.dataset.chart_information.width;

   // Convert the raw data JSON to the format required for the chart if required.
   var processedData = processData(options.dataset.data);

   // Do the actual drawing of the chart into $chartDiv.
   doDrawing(processedData, $chartDrawDiv, height, width, options.errorCallback);
},

processData = function(dataset) {
   // Data is in the dataset in a column based format, where each column has an array of data
    // eg. dataset.column_name[0].raw_data, dataset.column_name[0].formatted_data
    // CONFIGURE: Report should only show one product row. Add column with custom function "top N rank" to only show the top product. This column will be ignored in the chart. Needed meta columns in data view should be named: name, image (link to image) and link (link to product). Add additional metrics as much as you prefer, e.g.: revenue, quantity, ...
    processedData = {}

    for (data in dataset) {
      if(data.indexOf('rank') == -1);
        processedData[data] = dataset[data][0].raw_data;
    }

    return processedData;
},

doDrawing = function(data, $chartDiv, height, width, errorFunction) {

   // Use require to load the javascript libraries you need

   // Libraries we ship with and their location:
   // js/chartingLibraries/c3/c3
   // js/chartingLibraries/chartjs/Chart
   // js/chartingLibraries/d3_3.5.17/d3_3.5.17
   require(['js/chartingLibraries/custom/customCharts'], function(customCharts) {

       try {
           // Your chart draw code here
           $chartDiv.append(customCharts.topProduct(data.name, data.image, data.link, data));

       } catch(err){
           errorFunction(err);
       }
   });
}
