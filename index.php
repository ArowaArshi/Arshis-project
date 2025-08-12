<?php
// index.php — Bangladesh Air Quality Management System (read-only list)

declare(strict_types=1);

// --- DB connection (XAMPP defaults) ---
$host = 'localhost';
$user = 'root';
$pass = '';
$db   = 'bangladesh_air_quality';

mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
try {
    $conn = new mysqli($host, $user, $pass, $db);
    $conn->set_charset('utf8mb4');
} catch (Throwable $e) {
    http_response_code(500);
    exit('Database connection failed: ' . htmlspecialchars($e->getMessage(), ENT_QUOTES));
}

// --- pagination ---
$perPage = 50;
$page    = isset($_GET['page']) ? max(1, (int)$_GET['page']) : 1;
$offset  = ($page - 1) * $perPage;

// total rows
$totalRes = $conn->query("SELECT COUNT(*) AS c FROM air_quality");
$total    = (int)$totalRes->fetch_assoc()['c'];
$pages    = max(1, (int)ceil($total / $perPage));

// fetch page of data (latest first)
$stmt = $conn->prepare("
    SELECT id, station_id, pm25, pm10, co, no2, so2, o3,
           temperature, humidity, pressure, wind_speed, aqi, reading_time
    FROM air_quality
    ORDER BY reading_time DESC, id DESC
    LIMIT ?, ?
");
$stmt->bind_param('ii', $offset, $perPage);
$stmt->execute();
$res  = $stmt->get_result();
$rows = $res->fetch_all(MYSQLI_ASSOC);

function e($v): string { return htmlspecialchars((string)$v, ENT_QUOTES, 'UTF-8'); }
?>


<?php
// --- ENTROPY ANALYSIS: table (paginated) ---
$entPerPage = 50;
$ep         = isset($_GET['ep']) ? max(1, (int)$_GET['ep']) : 1;
$entOffset  = ($ep - 1) * $entPerPage;

$entTotal = (int)$conn->query("SELECT COUNT(*) AS c FROM entropy_analysis")->fetch_assoc()['c'];
$entPages = max(1, (int)ceil($entTotal / $entPerPage));

$entStmt = $conn->prepare("
  SELECT id, station_id, entropy_value, temperature, humidity, wind_speed, analysis_time, parameters
  FROM entropy_analysis
  ORDER BY analysis_time DESC, id DESC
  LIMIT ?, ?
");
$entStmt->bind_param('ii', $entOffset, $entPerPage);
$entStmt->execute();
$entRes  = $entStmt->get_result();
$entRows = $entRes->fetch_all(MYSQLI_ASSOC);

// --- ENTROPY ANALYSIS: line chart data (latest per station) ---
$entChartSql = "
  SELECT ea.station_id, ea.entropy_value
  FROM entropy_analysis ea
  JOIN (
    SELECT station_id, MAX(analysis_time) AS mt
    FROM entropy_analysis
    GROUP BY station_id
  ) m ON m.station_id = ea.station_id AND m.mt = ea.analysis_time
  ORDER BY ea.station_id
";
$ecr = $conn->query($entChartSql);
$entChartLabels = [];
$entChartValues = [];
while ($row = $ecr->fetch_assoc()) {
  $entChartLabels[] = (string)$row['station_id'];
  $entChartValues[] = (float)$row['entropy_value'];
}
?>



<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Bangladesh Air Quality Management System</title>

<link href="https://cdn.jsdelivr.net/npm/daisyui@5" rel="stylesheet" type="text/css" />
<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>

<script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>


<meta name="viewport" content="width=device-width,initial-scale=1">
<style>
  :root{--bd:#eaeaea;--bg:#fafafa;--tx:#111;--muted:#666}
  body{font:14px system-ui,-apple-system,Segoe UI,Roboto,Arial; color:var(--tx);}
  .wrap{max-width:1200px; margin:auto}
  h1{font-size:45px; margin:0 0 6px}
  p.lead{margin:0 0 18px; color:var(--muted)}
  .meta{margin:8px 0 16px; color:var(--muted)}
  table{border-collapse:collapse; width:100%}
  th,td{border:1px solid var(--bd); padding:6px 8px; vertical-align:top; white-space:nowrap}
  th{background:var(--bg); position:sticky; top:0; z-index:1}
  tbody tr:nth-child(odd){background:#fff}
  tbody tr:nth-child(even){background:#fcfcfc}
  .pager{display:flex; gap:8px; align-items:center; margin-top:14px}
  .pager a{border:1px solid var(--bd); padding:6px 10px; border-radius:8px; text-decoration:none; color:var(--tx)}
  .pager .muted{color:var(--muted)}
  .nowrap{white-space:nowrap}

</style>
</head>
<body>

    <div class="navbar bg-neutral text-neutral-content mb-20">
  <div class="navbar-start">
    <div class="dropdown">
      <div tabindex="0" role="button" class="btn btn-ghost lg:hidden">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"> <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h8m-8 6h16" /> </svg>
      </div>
      <ul
        tabindex="0"
        class="menu menu-sm dropdown-content bg-base-100 rounded-box z-1 mt-3 w-52 p-2 shadow">
              <li><a href="index.php">Home</a></li>
      <li><a href="#entropy">Entropy Data</a></li>
      <li><a href="addData.php">Add Data</a></li>
      </ul>
    </div>
    <a class="btn btn-ghost text-xl">Air Quality MIS</a>
  </div>
  <div class="navbar-center hidden lg:flex">
    <ul class="menu menu-horizontal px-1">
      <li><a href="index.php">Home</a></li>
      <li><a href="#entropy">Entropy Data</a></li>
      <li><a href="addData.php">Add Data</a></li>
    </ul>
  </div>
  <div class="navbar-end">
    <button class="btn btn-primary" id="btn-download-report" type="button">Download Report</button>
  </div>
</div>
<div class="wrap" id="report">


    <div class="flex flex-col md:flex-row gap-10 items-center">
        <div class="w-full md:w-1/2">
              <h1>Bangladesh Air Quality Management System</h1>
  <p class="lead">This page lists recent air-quality readings collected across monitoring stations. Use it to
  review PM metrics, gases, weather context, and calculated AQI values at a glance.</p>
        </div>

        <div class="mx-auto w-full md:w-1/2">
           <img src="./blog.png" alt='banner' class="w-full"> 
        </div>
</div>

<?php
// --- build data for the chart (latest AQI per station) ---
$chartSql = "
  SELECT aq.station_id, aq.aqi
  FROM air_quality aq
  JOIN (
      SELECT station_id, MAX(reading_time) AS mr
      FROM air_quality
      GROUP BY station_id
  ) m ON m.station_id = aq.station_id AND m.mr = aq.reading_time
  ORDER BY aq.station_id
";
$chartRes = $conn->query($chartSql);
$chartLabels = [];
$chartValues = [];
while ($r = $chartRes->fetch_assoc()) {
    $chartLabels[] = (string)$r['station_id'];
    $chartValues[] = (float)$r['aqi'];
}
?>

<!-- 1) Load Chart.js (CDN) -->
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.3/dist/chart.umd.min.js"></script>

<!-- 2) Canvas -->
<div class="chart-box" style="margin-top:28px">
  <canvas id="aqiChart" height="540"></canvas>
</div>

<!-- 3) Init chart AFTER the canvas + AFTER Chart.js is loaded -->
<script>
(function () {
  // Debug logs—open DevTools (F12) > Console if it still doesn’t render
  const labels = <?=json_encode($chartLabels, JSON_UNESCAPED_UNICODE)?>;
  const values = <?=json_encode($chartValues, JSON_UNESCAPED_UNICODE)?>;
  console.log('AQI labels:', labels, 'values:', values);

  function init() {
    if (!window.Chart) { console.error('Chart.js failed to load'); return; }
    const canvas = document.getElementById('aqiChart');
    if (!canvas) { console.error('Canvas #aqiChart not found'); return; }
    if (!labels || !labels.length) { console.warn('No data for chart'); return; }

    const ctx = canvas.getContext('2d');
    new Chart(ctx, {
      type: 'bar',
      data: {
        labels,
        datasets: [{
          label: 'Latest AQI by Station',
          data: values,
          backgroundColor: 'rgba(54, 162, 235, 0.4)',
          borderColor: 'rgba(54, 162, 235, 1)',
          borderWidth: 1
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
          y: { beginAtZero: true, title: { display: true, text: 'AQI' } },
          x: { title: { display: true, text: 'Station ID' } }
        },
        plugins: {
          legend: { display: false },
          title: { display: true, text: 'Latest AQI per Station' },
          tooltip: { callbacks: { label: (ctx) => `AQI: ${ctx.parsed.y}` } }
        }
      }
    });
  }

  // Make sure DOM is ready before we look for the canvas
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
</script>

  <div class="meta">Rows <?=e($total)?> · Page <?=e($page)?> / <?=e($pages)?></div>

  <table>
    <thead>
      <tr>
        <th>id</th>
        <th>station_id</th>
        <th>pm25</th>
        <th>pm10</th>
        <th>co</th>
        <th>no2</th>
        <th>so2</th>
        <th>o3</th>
        <th>temperature</th>
        <th>humidity</th>
        <th>pressure</th>
        <th>wind_speed</th>
        <th>aqi</th>
        <th>reading_time</th>
      </tr>
    </thead>
    <tbody>
      <?php if (!$rows): ?>
        <tr><td colspan="14" class="muted">No data found.</td></tr>
      <?php else: foreach ($rows as $r): ?>
        <tr>
          <td><?=e($r['id'])?></td>
          <td><?=e($r['station_id'])?></td>
          <td><?=e($r['pm25'])?></td>
          <td><?=e($r['pm10'])?></td>
          <td><?=e($r['co'])?></td>
          <td><?=e($r['no2'])?></td>
          <td><?=e($r['so2'])?></td>
          <td><?=e($r['o3'])?></td>
          <td><?=e($r['temperature'])?></td>
          <td><?=e($r['humidity'])?></td>
          <td><?=e($r['pressure'])?></td>
          <td><?=e($r['wind_speed'] ?? '—')?></td>
          <td><?=e($r['aqi'])?></td>
          <td class="nowrap"><?=e($r['reading_time'])?></td>
        </tr>
      <?php endforeach; endif; ?>
    </tbody>
  </table>

  <div class="pager">
    <?php if ($page > 1): ?>
      <a href="?page=<?=e($page-1)?>">&larr; Prev</a>
    <?php endif; ?>
    <span class="muted">Page <?=e($page)?> of <?=e($pages)?></span>
    <?php if ($page < $pages): ?>
      <a href="?page=<?=e($page+1)?>">Next &rarr;</a>
    <?php endif; ?>
  </div>



<hr style="margin:28px 0;border:0;border-top:1px solid #eaeaea">

<section id="entropy">
  <h2 class="text-3xl">Entropy Analysis</h2>
  <p class="lead">Latest entropy values per station (higher = more variability/uncertainty in conditions).</p>

  <div class="chart-box" style="margin-top:24px">
    <canvas id="entropyChart" height="540"></canvas>
  </div>

  <script>
(function () {
  const labels = <?=json_encode($entChartLabels, JSON_UNESCAPED_UNICODE)?>;
  const values = <?=json_encode($entChartValues, JSON_UNESCAPED_UNICODE)?>;
  console.log('Entropy labels:', labels, 'values:', values);

  function initEntropy() {
    if (!window.Chart) { console.error('Chart.js not loaded'); return; }
    const canvas = document.getElementById('entropyChart');
    if (!canvas) { console.error('#entropyChart not found'); return; }
    if (!labels || !labels.length) { console.warn('No entropy data'); return; }

    new Chart(canvas.getContext('2d'), {
      type: 'line',
      data: {
        labels,
        datasets: [{
          label: 'Latest Entropy by Station',
          data: values,
          tension: 0.25,
          fill: false,
          borderWidth: 2,
          pointRadius: 3
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        interaction: { mode: 'index', intersect: false },
        scales: {
          y: { beginAtZero: true, title: { display: true, text: 'Entropy' } },
          x: { title: { display: true, text: 'Station ID' } }
        },
        plugins: {
          legend: { display: false },
          title: { display: true, text: 'Entropy (latest) per Station' },
          tooltip: { callbacks: { label: (ctx) => `Entropy: ${ctx.parsed.y}` } }
        }
      }
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initEntropy);
  } else {
    initEntropy();
  }
})();
</script>



  <div class="meta">Rows <?=e($entTotal)?> · Page <?=e($ep)?> / <?=e($entPages)?></div>

  <table>
    <thead>
      <tr>
        <th>id</th>
        <th>station_id</th>
        <th>entropy_value</th>
        <th>temperature</th>
        <th>humidity</th>
        <th>wind_speed</th>
        <th>analysis_time</th>
        <th>parameters</th>
      </tr>
    </thead>
    <tbody>
      <?php if (!$entRows): ?>
        <tr><td colspan="8" class="muted">No data found.</td></tr>
      <?php else: foreach ($entRows as $r): ?>
        <tr>
          <td><?=e($r['id'])?></td>
          <td><?=e($r['station_id'])?></td>
          <td><?=e($r['entropy_value'])?></td>
          <td><?=e($r['temperature'])?></td>
          <td><?=e($r['humidity'])?></td>
          <td><?=e($r['wind_speed'] ?? '—')?></td>
          <td><?=e($r['analysis_time'])?></td>
          <td><?=e($r['parameters'])?></td>
        </tr>
      <?php endforeach; endif; ?>
    </tbody>
  </table>

  <div class="pager">
    <?php if ($ep > 1): ?>
      <a href="?ep=<?=e($ep-1)?>#entropy">&larr; Prev</a>
    <?php endif; ?>
    <span class="muted">Page <?=e($ep)?> of <?=e($entPages)?></span>
    <?php if ($ep < $entPages): ?>
      <a href="?ep=<?=e($ep+1)?>#entropy">Next &rarr;</a>
    <?php endif; ?>
  </div>


</section>


</div>

<footer class="footer sm:footer-horizontal bg-neutral text-neutral-content items-center p-4 mt-20">
  <aside class="grid-flow-col items-center">
    <svg
      width="36"
      height="36"
      viewBox="0 0 24 24"
      xmlns="http://www.w3.org/2000/svg"
      fill-rule="evenodd"
      clip-rule="evenodd"
      class="fill-current">
      <path
        d="M22.672 15.226l-2.432.811.841 2.515c.33 1.019-.209 2.127-1.23 2.456-1.15.325-2.148-.321-2.463-1.226l-.84-2.518-5.013 1.677.84 2.517c.391 1.203-.434 2.542-1.831 2.542-.88 0-1.601-.564-1.86-1.314l-.842-2.516-2.431.809c-1.135.328-2.145-.317-2.463-1.229-.329-1.018.211-2.127 1.231-2.456l2.432-.809-1.621-4.823-2.432.808c-1.355.384-2.558-.59-2.558-1.839 0-.817.509-1.582 1.327-1.846l2.433-.809-.842-2.515c-.33-1.02.211-2.129 1.232-2.458 1.02-.329 2.13.209 2.461 1.229l.842 2.515 5.011-1.677-.839-2.517c-.403-1.238.484-2.553 1.843-2.553.819 0 1.585.509 1.85 1.326l.841 2.517 2.431-.81c1.02-.33 2.131.211 2.461 1.229.332 1.018-.21 2.126-1.23 2.456l-2.433.809 1.622 4.823 2.433-.809c1.242-.401 2.557.484 2.557 1.838 0 .819-.51 1.583-1.328 1.847m-8.992-6.428l-5.01 1.675 1.619 4.828 5.011-1.674-1.62-4.829z"></path>
    </svg>
    <p>Copyright © AirQuality MIS - All right reserved</p>
  </aside>
  <nav class="grid-flow-col gap-4 md:place-self-center md:justify-self-end">
    <a>
      <svg
        xmlns="http://www.w3.org/2000/svg"
        width="24"
        height="24"
        viewBox="0 0 24 24"
        class="fill-current">
        <path
          d="M24 4.557c-.883.392-1.832.656-2.828.775 1.017-.609 1.798-1.574 2.165-2.724-.951.564-2.005.974-3.127 1.195-.897-.957-2.178-1.555-3.594-1.555-3.179 0-5.515 2.966-4.797 6.045-4.091-.205-7.719-2.165-10.148-5.144-1.29 2.213-.669 5.108 1.523 6.574-.806-.026-1.566-.247-2.229-.616-.054 2.281 1.581 4.415 3.949 4.89-.693.188-1.452.232-2.224.084.626 1.956 2.444 3.379 4.6 3.419-2.07 1.623-4.678 2.348-7.29 2.04 2.179 1.397 4.768 2.212 7.548 2.212 9.142 0 14.307-7.721 13.995-14.646.962-.695 1.797-1.562 2.457-2.549z"></path>
      </svg>
    </a>
    <a>
      <svg
        xmlns="http://www.w3.org/2000/svg"
        width="24"
        height="24"
        viewBox="0 0 24 24"
        class="fill-current">
        <path
          d="M19.615 3.184c-3.604-.246-11.631-.245-15.23 0-3.897.266-4.356 2.62-4.385 8.816.029 6.185.484 8.549 4.385 8.816 3.6.245 11.626.246 15.23 0 3.897-.266 4.356-2.62 4.385-8.816-.029-6.185-.484-8.549-4.385-8.816zm-10.615 12.816v-8l8 3.993-8 4.007z"></path>
      </svg>
    </a>
    <a>
      <svg
        xmlns="http://www.w3.org/2000/svg"
        width="24"
        height="24"
        viewBox="0 0 24 24"
        class="fill-current">
        <path
          d="M9 8h-3v4h3v12h5v-12h3.642l.358-4h-4v-1.667c0-.955.192-1.333 1.115-1.333h2.885v-5h-3.808c-3.596 0-5.192 1.583-5.192 4.615v3.385z"></path>
      </svg>
    </a>
  </nav>
</footer>

<script>
  document.getElementById('btn-download-report')?.addEventListener('click', () => {
    const el = document.getElementById('report');
    if (!el) return;

 
    const opt = {
      margin:       10,                                  
      filename:     'air-quality-report.pdf',
      image:        { type: 'jpeg', quality: 0.98 },
      html2canvas:  { scale: 2, useCORS: true, letterRendering: true },
      jsPDF:        { unit: 'mm', format: 'a4', orientation: 'landscape' },
      pagebreak:    { mode: ['avoid-all', 'css', 'legacy'] }
    };


    setTimeout(() => html2pdf().set(opt).from(el).save(), 100);
  });
</script>
</body>
</html>
