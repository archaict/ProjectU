<?php

include "koneksi.php";
$query = mysql_query("SELECT * FROM mhs ORDER BY name ASC");
$json = array();
while($row = mysql_fetch_assoc($query)){
  $json[] = $row;
}

echo json_encode($json);
mysql_close($connect);

?>
