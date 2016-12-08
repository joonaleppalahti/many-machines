# Includes hostnames starting with "v" followed by any numbers
node /^v\d+$/ {
	class {physical:}
}

# Same as above but with "t"
node /^t\d+$/ {
	class {virtual:}
}
