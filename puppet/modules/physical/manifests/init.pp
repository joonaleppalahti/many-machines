class physical {

	file { "/etc/vagrantinstall":
		ensure => "directory"
	}

	file { "/etc/vagrantinstall/Vagrantfile":
		content => template("physical/Vagrantfile"),
	}

	file { "/etc/vagrantinstall/provision.sh":
		content => template("physical/provision.sh"),
	}

	exec { "vagrant up":
		timeout => 0,
		command => "sudo vagrant up",
		path => "/bin/:/usr/bin/:/sbin/:/usr/sbin/",
		cwd => "/etc/vagrantinstall"
	}

}
