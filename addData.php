<?php
// addData.php — Insert into entropy_analysis (mysqli version, clean)

declare(strict_types=1);
ini_set('display_errors', '1'); error_reporting(E_ALL);

// ---- Session + CSRF ----
session_name('aqmis_session');
session_set_cookie_params([
  'lifetime' => 0, 'path' => '/', 'secure' => false, 'httponly' => true, 'samesite' => 'Lax'
]);
session_start();
if (empty($_SESSION['csrf'])) $_SESSION['csrf'] = bin2hex(random_bytes(32));
$csrf = $_SESSION['csrf'];

// ---- DB (mysqli) ----
mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
try {
  $conn = new mysqli('localhost', 'root', '', 'bangladesh_air_quality');
  $conn->set_charset('utf8mb4');
} catch (Throwable $e) {
  http_response_code(500);
  exit('DB connection failed: ' . htmlspecialchars($e->getMessage(), ENT_QUOTES));
}

function e($v): string { return htmlspecialchars((string)$v, ENT_QUOTES); }

$errors = [];
$okMsg  = null;
$old    = [];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
  // CSRF
  if (!isset($_POST['csrf']) || !hash_equals($_SESSION['csrf'], (string)$_POST['csrf'])) {
    $errors[] = 'Invalid form token. Please refresh and try again.';
  }

  // Gather
  $old['station_id']    = trim((string)($_POST['station_id'] ?? ''));
  $old['entropy_value'] = trim((string)($_POST['entropy_value'] ?? ''));
  $old['temperature']   = trim((string)($_POST['temperature'] ?? ''));
  $old['humidity']      = trim((string)($_POST['humidity'] ?? ''));
  $old['wind_speed']    = trim((string)($_POST['wind_speed'] ?? '')); // allow blank → NULL
  $old['analysis_time'] = trim((string)($_POST['analysis_time'] ?? ''));
  $old['parameters']    = trim((string)($_POST['parameters'] ?? ''));

  // Validate
  $stationId = filter_var($old['station_id'], FILTER_VALIDATE_INT, ['options' => ['min_range' => 1]]);
  if ($stationId === false) $stationId = null;
  if ($stationId === null) $errors[] = 'station_id must be a positive integer.';

  $entropy = filter_var($old['entropy_value'], FILTER_VALIDATE_FLOAT);
  if ($entropy === false) $errors[] = 'entropy_value must be numeric.';

  $temp = filter_var($old['temperature'], FILTER_VALIDATE_FLOAT);
  if ($temp === false) $errors[] = 'temperature must be numeric.';

  $humid = filter_var($old['humidity'], FILTER_VALIDATE_FLOAT);
  if ($humid === false) $errors[] = 'humidity must be numeric.';

  // wind_speed: keep as string; SQL will do NULLIF(?, '') to turn blank -> NULL
  $windStr = $old['wind_speed']; // no validation needed if you want to allow blank→NULL
  if ($windStr !== '' && filter_var($windStr, FILTER_VALIDATE_FLOAT) === false) {
    $errors[] = 'wind_speed must be numeric or left blank.';
  }

  // analysis_time
  if ($old['analysis_time'] === '') {
    $errors[] = 'analysis_time is required.';
    $analysisSql = null;
  } else {
    $dt = DateTime::createFromFormat('Y-m-d\TH:i', $old['analysis_time']);
    if (!$dt) $dt = date_create($old['analysis_time']); // fallback
    $analysisSql = $dt ? $dt->format('Y-m-d H:i:s') : null;
    if (!$analysisSql) $errors[] = 'analysis_time is invalid.';
  }

  if ($old['parameters'] === '') {
    $errors[] = 'parameters is required.';
  } elseif (mb_strlen($old['parameters']) > 100) {
    $errors[] = 'parameters must be at most 100 characters.';
  }

  // Insert
  if (!$errors) {
    $sql = "
      INSERT INTO entropy_analysis
        (station_id, entropy_value, temperature, humidity, wind_speed, analysis_time, parameters)
      VALUES
        (?, ?, ?, ?, NULLIF(?, ''), ?, ?)
    ";
    $stmt = $conn->prepare($sql);
    // Types: i=station, d=entropy, d=temp, d=humidity, s=wind as string ('' -> NULL), s=analysis, s=params
    $stmt->bind_param('idddsss', $stationId, $entropy, $temp, $humid, $windStr, $analysisSql, $old['parameters']);
    $stmt->execute();

    $okMsg = 'Row inserted (id #' . $stmt->insert_id . ').';
    $stmt->close();

    // Reset form
    $old = [
      'station_id'    => '',
      'entropy_value' => '',
      'temperature'   => '',
      'humidity'      => '',
      'wind_speed'    => '',
      'analysis_time' => date('Y-m-d\TH:i'),
      'parameters'    => '',
    ];
  }
}

if (!isset($old['analysis_time'])) $old['analysis_time'] = date('Y-m-d\TH:i');
?>
<!doctype html>
<html lang="en" data-theme="light">
<head>
  <meta charset="utf-8" />
  <title>Add Entropy Analysis</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />


  <!-- Tailwind + DaisyUI CDNs -->
<link href="https://cdn.jsdelivr.net/npm/daisyui@5" rel="stylesheet" type="text/css" />
<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>



</head>
<body class="min-h-screen bg-base-200 text-base-content">

    <div class="navbar bg-neutral text-neutral-content mb-10">
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
    <a class="btn btn-primary">Download Report</a>
  </div>
</div>


  <main class="max-w-3xl mx-auto p-6">
    <h1 class="text-3xl text-center mb-2 font-semibold">Add Entropy Analysis</h1>
    <p class="mb-4 text-base-content/70 text-center">Create a new record in <code>entropy_analysis</code>. Fields follow your table schema.</p>

    <?php if ($errors): ?>
      <div class="alert alert-error mb-4"><span><strong>There were errors:</strong> <?=e(implode(' ', $errors))?></span></div>
    <?php elseif ($okMsg): ?>
      <div class="alert alert-success mb-4"><span><?=e($okMsg)?></span></div>
    <?php endif; ?>

    <form method="post" action="addData.php" class="space-y-6">
      <input type="hidden" name="csrf" value="<?=e($csrf)?>">

      <fieldset class="fieldset bg-base-100 border-base-300 rounded-box border p-4">
        <legend class="fieldset-legend">Entropy Analysis</legend>

        <label class="label">station_id (INT)</label>
        <input name="station_id" type="number" min="1" step="1" value="<?=e($old['station_id'] ?? '')?>" class="input input-bordered w-full" placeholder="e.g., 7" required />

        <label class="label">entropy_value (DECIMAL 10,6)</label>
        <input name="entropy_value" type="number" step="0.000001" value="<?=e($old['entropy_value'] ?? '')?>" class="input input-bordered w-full" placeholder="e.g., 2.345678" required />

        <label class="label">temperature (DECIMAL 4,2)</label>
        <input name="temperature" type="number" step="0.01" min="-50" max="100" value="<?=e($old['temperature'] ?? '')?>" class="input input-bordered w-full" placeholder="e.g., 29.30" required />

        <label class="label">humidity (DECIMAL 5,2)</label>
        <input name="humidity" type="number" step="0.01" min="0" max="100" value="<?=e($old['humidity'] ?? '')?>" class="input input-bordered w-full" placeholder="e.g., 63.80" required />

        <label class="label">wind_speed (DECIMAL 4,2) — optional</label>
        <input name="wind_speed" type="number" step="0.01" min="0" value="<?=e($old['wind_speed'] ?? '')?>" class="input input-bordered w-full" placeholder="leave blank for NULL" />

        <label class="label">analysis_time (DATETIME)</label>
        <input name="analysis_time" type="datetime-local" value="<?=e($old['analysis_time'] ?? '')?>" class="input input-bordered w-full" required />

        <label class="label">parameters (VARCHAR 100)</label>
        <input name="parameters" type="text" maxlength="100" value="<?=e($old['parameters'] ?? '')?>" class="input input-bordered w-full" placeholder="e.g., basic" required />

        <button class="btn btn-neutral mt-4">Save</button>
      </fieldset>
    </form>

    <div class="mt-6">
      <a class="btn btn-outline" href="./index.php">← Back to index</a>
    </div>
  </main>


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
</body>
</html>
