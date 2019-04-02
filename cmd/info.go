package cmd

import (
	"github.com/crypdex/blackbox/system"

	"github.com/crypdex/blackbox/docker"

	"github.com/spf13/cobra"
	"github.com/spf13/viper"
	yaml "gopkg.in/yaml.v2"
)

// versionCmd represents the version command
var infoCmd = &cobra.Command{
	Use:   "info",
	Short: "Displays the current configuration",
	Run: func(cmd *cobra.Command, args []string) {
		displayBlackboxInfo()

		client := docker.NewClient(env)
		client.ComposeConfig()
	},
}

func displayBlackboxInfo() {
	system.PrintInfo("version:", version)
	system.PrintInfo("commit:", commit)
	system.PrintInfo("date:", date)

	settings, _ := yaml.Marshal(viper.AllSettings())
	system.PrintInfo("config_file:", viper.ConfigFileUsed())
	system.PrintInfo("config:\n", string(settings))
}

func init() {
	rootCmd.AddCommand(infoCmd)
}
