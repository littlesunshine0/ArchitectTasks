.PHONY: install uninstall clean setup

setup:
	@echo "🚀 Starting ArchitectTasks Setup..."
	@swift run architect-setup

install:
	@echo "🔨 Installing ArchitectTasks Xcode Extension..."
	@./install-extension.swift

uninstall:
	@echo "🗑️  Uninstalling ArchitectTasks..."
	@sudo rm -rf /Applications/ArchitectTasks.app
	@echo "✅ Uninstalled"
	@echo "⚠️  Restart Xcode to complete removal"

clean:
	@rm -rf .build
	@echo "✅ Build artifacts cleaned"
