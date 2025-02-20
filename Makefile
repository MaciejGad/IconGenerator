all: icon_gen

icon_gen: icon_gen.swift
	swiftc icon_gen.swift -o icon_gen

clean:
	rm -f icon_gen