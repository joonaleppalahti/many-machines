class physical {

	Package { ensure => "installed" }

	package { virtualbox: }
	package { vagrant: 
		require => Package["virtualbox"],
	}

	file { "/home/joona/vagrantinstall":
		ensure => "directory",
		owner => "joona",
		group => "joona",
		mode => 0755,
	}

	file { "/home/joona/vagrantinstall/Vagrantfile":
		content => template("physical/Vagrantfile"),
		owner => "joona",
		group => "joona",
		mode => 0644,
	}

	file { "/home/joona/vagrantinstall/provision.sh":
		content => template("physical/provision.sh"),
		owner => "joona",
		group => "joona",
		mode => 0755,
	}

	exec { "vagrant up":
		timeout => 0,
		command => "vagrant up",
		cwd => "/home/joona/vagrantinstall",
		user => "joona",
		path => "/bin/:/usr/bin/:/sbin/:/usr/sbin/",
		environment => ["HOME=/home/joona"],
		require => [ Package["vagrant"], File["/home/joona/vagrantinstall/Vagrantfile"], File["/home/joona/vagrantinstall/provision.sh"] ],
	}

}
