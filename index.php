<?php
function connect_db()
{
    return new mysqli("mysql.hostinger.ru","u828700449_holy","1qw23er4","u828700449_holy");
}

function registration($FIELD0, $FIELD1, $FIELD2, $FIELD3, $FIELD4)
{
    $BD=connect_db();
    $res = $BD->query("SELECT name FROM ROUTE WHERE name = '$FIELD0'");
    if($res->num_rows < 1) {
        $BD->query("INSERT INTO ROUTE(name, family, pass, login, email) VALUES('$FIELD0', '$FIELD1', '$FIELD2', '$FIELD3', '$FIELD4')");
        return "yes";
    }
    return "no";
}

function authentication($FIELD0, $FIELD1)
{
    $BD=connect_db();
    $res = $BD->query("SELECT * FROM ROUTE WHERE name = '$FIELD0' AND pass = '$FIELD1'");
    return $res->num_rows>0? json_encode(mysqli_fetch_object($res)): "no";
}

function users($FIELD0, $FIELD1, $FIELD2)
{
    $BD=connect_db();
    $res = $BD->query("SELECT wide FROM USERS WHERE wide = '$FIELD0'");
    if($res->num_rows > 0)
    $BD->query("UPDATE USERS SET ip = '$FIELD1', port = '$FIELD2' WHERE wide = '$FIELD0'");
    else
    $BD->query("INSERT INTO USERS(wide, ip, port) VALUES('$FIELD0','$FIELD1', '$FIELD2')");
}

function route($FIELD0, $FIELD1, $FIELD2, $FIELD3, $FIELD4)
{
    $BD=connect_db();
    if ($FIELD3=="" && $FIELD4=="") {
    $BD->query("UPDATE ROUTE SET ip = '$FIELD1', port = '$FIELD2' WHERE name = '$FIELD0'");
    }
    $row = mysqli_fetch_array($BD->query("SELECT friend FROM ROUTE WHERE name='$FIELD0'"));
    $obj = json_decode($row['friend'],true);
    if($FIELD3!="" && !in_array($FIELD3, $obj)) {
        if ($FIELD4 == "false") {
            array_push($obj,$FIELD3);
	} else {
	    $i = array_search($FIELD3,$obj);
	    array_splice($obj,$i, 1);
	}
        $json = json_encode($obj);
        $BD->query("UPDATE ROUTE SET friend='$json' WHERE name = '$FIELD0'");
    }
}

if (isset($_POST['READ'])) {
    $BD=connect_db();
    $FIELD0 = $_POST['name'];
    switch ($_POST['READ']) {
    case 1:
    $res=$BD->query("SELECT ip, port FROM USERS WHERE wide='$FIELD0'");
    $row=$res->fetch_array();
    echo $row['port'] . "|" . $row['ip'];
    break;
    case 2:
    $friendsArray = json_decode($FIELD0);
    foreach($friendsArray as $friendName) {
        $res=$BD->query("SELECT ip, port, name, family,login FROM ROUTE WHERE name='$friendName'");
        while($row=mysqli_fetch_object($res)) $array[]=$row;
    }
    echo json_encode($array);
    break;
    case 3:
    $res=$BD->query("SELECT friend FROM ROUTE WHERE name = '$FIELD0'");
    $row=$res->fetch_array();
    echo $row['friend'];
    break;
    case 4:
    $res=$BD->query("SELECT ip, port, name, family, login FROM ROUTE");
    while($row=mysqli_fetch_object($res)) $array[]=$row;
    echo json_encode($array);
    break;
    }
}
elseif(isset($_POST['mail']))
    echo registration($_POST['name'], $_POST['family'], $_POST['pass'], $_POST['login'], $_POST['mail']);
elseif(isset($_POST['wide']))
    users($_POST['wide'], $_POST['ip'], $_POST['port']);
elseif(isset($_POST['pass']))
    echo authentication($_POST['phone'],$_POST['pass']);
else {
    $friend="";
    if(isset($_POST['friend'])) {
        $friend=$_POST['friend'];
    }
    $del="";
    if(isset($_POST['remove'])) {
        $del=$_POST['remove'];
    }
    route($_POST['name'], $_POST['ip'], $_POST['port'], $friend, $del);
}

/*
$iosocket = socket_create(AF_INET, SOCK_DGRAM, SOL_UDP);
socket_bind($iosocket,'localhost', 8888);
socket_recvfrom($iosocket, $buff, 100, 0, $rip, $rport);
users($buff, $rip, $rport);
echo "Received ".$buff." from ".$rip."|".$rport;
*/
?>