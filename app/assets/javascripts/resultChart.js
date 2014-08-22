$( '.home.results' ).ready(function() {
  console.log('chart loaded bro!');
  getLabels();
  getData();

  var data = {
  labels: dates,
      datasets: [
          {
              label: "My First dataset",
              fillColor: "rgba(151,187,205,0.2)",
              strokeColor: "rgba(151,187,205,1)",
              pointColor: "rgba(151,187,205,1)",
              pointStrokeColor: "#fff",
              pointHighlightFill: "#fff",
              pointHighlightStroke: "rgba(151,187,205,1)",
              data: tweets
          }
        ]
  };

    var options = {scaleShowGridLines: true};
    var ctx = $("#myChart").get(0).getContext("2d");
    var myNewChart = new Chart(ctx);
    var myLineChart = new Chart(ctx).Line(data, options);

});

function getLabels(){
  dates = jQuery.parseJSON($('#tpd_keys').html());
}

function getData(){
  tweets = jQuery.parseJSON($('#tpd_values').html());
}
