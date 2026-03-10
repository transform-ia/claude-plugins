package main

import "github.com/transform-ia/gokit"

func main() {
	gokit.Run(gokit.App{
		Name:  "myapp",
		Short: "My application description",
		Commands: []gokit.Command{
			gokit.ServeCommand[ServeConfig]("serve", "Start HTTP server", routes),
			gokit.NewCommand[WorkerConfig]("worker", "Start background worker", runWorker),
		},
	})
}
