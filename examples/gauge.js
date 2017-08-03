//generateChart is a required function which will be called to generate your Javascript chart
generateChart = function(options) {
   console.log(options);
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
   // CONFIGURE: replace metrics you want to show
   var metrics = [ "sessions_ytd", "sessions_target"]
   var data_array = []
   var data = {}
   var data_target = {}
   var max = 25;
   var min = -25;
   range = Math.abs(min) +  Math.abs(max)
   var val = parseFloat(dataset[metrics[0] + '_growth'][0].raw_data);
   if (val >= max) {
       val = max
   } else if (val <= min) {
       val = min
   }
   data.metric = metrics[0]
   data.percent = dataset[metrics[0] + '_growth'][0].raw_data;
   data.value = dataset[metrics[0]][0].formatted_data
   data.gauge = (val + (range/2)) / range;
   console.log(data);
   data_array[0]=data;

   data_target.metric = metrics[1]
   data_target.percent = dataset[metrics[1] + '_growth'][0].raw_data;
   data_target.value = dataset[metrics[1]][0].formatted_data

   console.log(data);
   data_array[1]=data_target;

   return data_array
},

doDrawing = function(data, $chartDiv, height, width, errorFunction) {

   // Use require to load the javascript libraries you need

   // Libraries we ship with and their location:
   // js/chartingLibraries/c3/c3
   // js/chartingLibraries/chartjs/Chart
   // js/chartingLibraries/d3_3.5.17/d3_3.5.17
   require(['js/chartingLibraries/custom/customCharts'], function(customCharts) {

       try {
            var info = document.createElement('div');
            info.setAttribute('style', 'float: left; clear: left; text-align: center; width: 100%');
            info.className = 'gauge-info';
            info.innerHTML = '<div style="display: inline-block; width: 250px;"><div style="float:left;"><h4 style="text-align: left;">Sessions</h4><p style="text-align: left;font-size:10px;">Growth vs. Previous Year</p></div></div>';
            var gauge = document.createElement('div');
            gauge.id = 'chart-gauge-' + data[0].metric;
            gauge.className = 'chart-gauge';
            var numbers = document.createElement('div');
            numbers.className = 'gauge-numbers';
            numbers.setAttribute('style', 'float: left; clear: left; width: 100%;');
            if (data[0].percent > 0) {
                numbers.innerHTML = '<h2 style="text-align: center">+' + data[0].percent.toFixed(2) + '%';
            } else {
                numbers.innerHTML = '<h2 style="text-align: center">' + data[0].percent.toFixed(1) +'%';
            }
            numbers.innerHTML +='<div class="data-table">'
                    +'<div class="rectangle" align="center">'
                        +'<div class="data-title">'+"YTD"+'</div>'
                        +'<div class="data">'+data[0].value+'</div>'
                        +'<div class="data-growth">'+data[0].percent.toFixed(1)+'%</div>'
                    +'</div>'
                    +'<div class="rectangle" align="center">'
                        +'<div class="data-title">'+ "Target"+'</div>'
                        +'<div class="data">'+data[1].value+'</div>'
                        +'<div class="data-growth">'+data[1].percent.toFixed(1)+'%</div>'
                    +'</div>'
                +'</div>'

            $chartDiv.append(info).append(gauge).append(numbers);
            customCharts.gauge(data[0].gauge, '#chart-gauge-' + data[0].metric);

       } catch(err){
           errorFunction(err);
       }
   });
}
