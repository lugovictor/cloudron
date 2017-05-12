<?php
namespace FileRun\Utils;
use \PDO, \PDOException;

class DB extends PDO {
	public $debug;
	private $fetchMode = PDO::FETCH_ASSOC;

	function __construct($dsn, $username, $password, $options = [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]) {
		try {
			parent::__construct($dsn, $username, $password, $options);
			global $config;
			if ($config['system']['db']['utf8_names']) {
				$this->exec("set names utf8");
			}
			$this->exec("SET SESSION sql_mode = ''");
		} catch (PDOException $e) {
			exit('Database error: '.$e->getMessage());
		}
	}

	function query($q) {
		try {
			if ($this->debug) {
				echo "\r\n".$q."<br>\r\n";
			}
			return parent::query($q);
		} catch (PDOException $e) {
			global $config, $fm;
			if ($config['debug']['sql_errors']) {
				echo 'Query error: ' . $e->getMessage() . ' in ' . $q;
				exit();
			} else {
				$entry = "\n\r".date('c')." - ".$q."\n".$e->getMessage()."\n";
				$logFile = $config['path']['temp'].'/mysql_error.log';
				if (!is_file($logFile)) {
					$fm->newFile($logFile, $entry);
				} else {
					$fm->appendData($logFile, $entry, 'bottom');
				}
			}
		}
	}

	function qstr($s) {
		return $this->quote($s);
	}

	function SetFetchMode($mode) {
		$this->fetchMode = $mode;
	}

	function GetAll($q) {
		return $this->query($q)->fetchAll($this->fetchMode);
	}

	function GetRow($q) {
		return $this->query($q)->fetch($this->fetchMode);
	}

	function GetOne($q) {
		return $this->query($q)->fetchColumn(0);
	}

	function FoundRows() {
		return $this->GetOne("SELECT FOUND_ROWS()");
	}

	function Insert_ID() {
		return $this->lastInsertId();
	}

}
