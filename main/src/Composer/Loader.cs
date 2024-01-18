using Godot;
using System.Collections.Generic;

namespace ComposerLib
{
    internal class LoaderScene
    {
        public Scene Scene {get; set;}
        public bool UseSubthreads {get; set;} = false;
        public ResourceLoader.CacheMode CacheMode = ResourceLoader.CacheMode.Reuse;
    }

    internal partial class Loader : Node
    {
        [Signal]
        internal delegate void LoaderStartedEventHandler(Scene scene);

        [Signal]
        internal delegate void LoaderLoadingUpdatedEventHandler(Scene scene, float progress);

        [Signal]
        internal delegate void LoaderFinishedEventHandler(Scene scene, PackedScene resource=null);

        private static Queue<LoaderScene> SceneQueue = new();
        private static LoaderScene CurrentLoadedObject = null;

        internal static void AddToQueue(LoaderScene scene)
        {
            SceneQueue.Enqueue(scene);
        }

        public override void _Process(double delta)
        {
            base._Process(delta);

            if (CurrentLoadedObject == null)
            {
                if (SceneQueue.Count > 0)
                {
                    BeginNewLoad();
                }
                else return;
            }

            Godot.Collections.Array progress = new();

            switch (ResourceLoader.LoadThreadedGetStatus(CurrentLoadedObject.Scene.Path, progress))
            {
                case ResourceLoader.ThreadLoadStatus.InProgress:
                {
                    EmitSignal(SignalName.LoaderLoadingUpdated, (float)progress[0]);
                    break;
                }
                case ResourceLoader.ThreadLoadStatus.Loaded:
                {
                    var resource = (PackedScene)ResourceLoader.LoadThreadedGet(CurrentLoadedObject.Scene.Path);
                    EmitSignal(SignalName.LoaderFinished, CurrentLoadedObject.Scene, resource);
                    EndLoad();
                    break;
                }
                case ResourceLoader.ThreadLoadStatus.Failed: case ResourceLoader.ThreadLoadStatus.InvalidResource:
                {
                    EmitSignal(SignalName.LoaderFinished, CurrentLoadedObject.Scene);
                    EndLoad();
                    break;
                }
            }
        }

        private void BeginNewLoad()
        {
            CurrentLoadedObject = SceneQueue.Dequeue();
            LoaderFinished += CurrentLoadedObject.Scene.OnLoaded;
            EmitSignal(SignalName.LoaderStarted, CurrentLoadedObject.Scene);
            ResourceLoader.LoadThreadedRequest(CurrentLoadedObject.Scene.Path, "PackedScene", CurrentLoadedObject.UseSubthreads, CurrentLoadedObject.CacheMode);
        }

        private void EndLoad()
        {
            LoaderFinished -= CurrentLoadedObject.Scene.OnLoaded;
            CurrentLoadedObject = null;
        }
    }
}