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
   processedData = [];
   rows = ["income", "cost"];

   rows.forEach(function(row, index) {
    var sparkline = [];
    var data = 0;
    var sum = 0
    var min, max = null;

    for (var x = 0; x < dataset[row].length; x++) {
        data = dataset[row][x].raw_data;
        sum = sum + data;
        if(min == null || min > data) min = data;
        if(max == null || max < data) max = data;
        sparkline.push({"x": x, "y": dataset[row][x].raw_data});
    }

    processedData[row] = [];
    processedData[row][''] = row;
    processedData[row]['sum'] = sum;
    processedData[row]['min'] = min;
    processedData[row]['max'] = max;
    processedData[row]["sparkline"] = sparkline;
   })

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
            var table = document.createElement('table');
            table.id = 'dataTable';
            $chartDiv.append(table);

            var order = ['', 'sum', 'min', 'max', 'sparkline'];
            customCharts.tableSparklines(width, data, order, table.id);

       } catch(err){
            errorFunction(err);
       }
   });
}
