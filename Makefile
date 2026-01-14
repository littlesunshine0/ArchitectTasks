.PHONY: install uninstall clean

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
