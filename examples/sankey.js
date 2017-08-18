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
    data = {};
    /// CONFIGURE: for data view: everything in column (dimensions and metric)
    data.dimensions = ["athlete_region", "gender", "age_group_at_camp"];
    data.metric = "athletes";

    data.dataset = dataset;

    return data;
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
            var chart = document.createElement("div");
            chart.id = "chart";
            chart.style.height = height + 'px';
            chart.style.width = width + 'px';
            $chartDiv.append(chart);

            customCharts.sankey(data.dataset, data.dimensions, data.metric, "#chart");

       } catch(err){
            errorFunction(err);
       }
   });
}
