.PHONY: install uninstall clean setup optimize spring-clean spring-clean-gui

setup:
	@echo "🚀 Starting ArchitectTasks Setup..."
	@swift run architect-setup

install:
	@echo "🔨 Installing ArchitectTasks Xcode Extension..."
	@./install-extension.swift

optimize:
	@echo "🧹 Optimizing project storage..."
	@swift run architect-clean .

spring-clean:
	@echo "🌸 Running system spring cleaning..."
	@cd SpringClean && sudo ./spring-clean.swift

spring-clean-gui:
	@echo "🌸 Building Spring Clean GUI..."
	@cd SpringClean && ./build.sh

uninstall:
	@echo "🗑️  Uninstalling ArchitectTasks..."
	@sudo rm -rf /Applications/ArchitectTasks.app
	@sudo rm -rf "/Applications/Spring Clean.app"
	@echo "✅ Uninstalled"

clean:
	@rm -rf .build
	@echo "✅ Build artifacts cleaned"
