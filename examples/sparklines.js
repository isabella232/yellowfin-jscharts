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
   // CONFIGURE: for data you need a column using the custom fuction Group Concat (hear it is called 'sparkline') to show the sparkline inside the table, only one sparkline possible
   for (var col in dataset) {
       if (col.indexOf('sparkline') > -1) {
            for (var row = 0; row < dataset[col].length; row++) {
                var string = dataset[col][row].raw_data
                var sparkline = [];
                var data = JSON.parse("[" + string + "]");
                for (var i = 0; i < data.length; i++) {
                    sparkline.push({"x": i, "y": data[i]});
                }
                dataset[col][row].formatted_data = sparkline
            }
       }
   }

   return dataset;
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
            var table = document.createElement('table');
            table.id = 'dataTable';
            $chartDiv.append(table);

            var order = ['age_group', 'sum', 'minimum', 'maximum', 'sparkline']
            customCharts.tableSparklines(width, data, order, table.id);

       } catch(err){
            errorFunction(err);
       }
   });
}
