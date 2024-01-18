using Godot;

namespace ComposerLib
{
    public partial class Scene : Resource
    {
        [Signal]
        public delegate void FinishedLoadingEventHandler(string sceneName);

        [Signal]
        public delegate void FinishedCreatingEventHandler(string sceneName);

        [Export]
        public string InternalName {get; private set;}
        [Export]
        public string Path {get; set;}
        [Export]
        public PackedScene Resource {get; set;} = null;
        public Node Instance {get; private set;} = null;

        public Scene(string internalName, string path)
        {
            InternalName = internalName;
            Path = path;
        }

        public Scene(string internalName, PackedScene resource, string path = "")
        {
            InternalName = internalName;
            Resource = resource;
            Path = path;
        }

        public void Load(bool UseSubthreads = false, ResourceLoader.CacheMode CacheMode = ResourceLoader.CacheMode.Reuse)
        {
            if (Resource != null || Path == "") return;

            Loader.AddToQueue(new LoaderScene(){
                Scene = this,
                UseSubthreads = UseSubthreads,
                CacheMode = CacheMode
            });
        }

        public void Create(Node parent)
        {
            if (Resource == null)
            {
                GD.PrintErr($"Create error for scene {InternalName}: Resource doesn't exist in memory.");
                return;
            }

            Instance = Resource.Instantiate();
            parent.AddChild(Instance);

            EmitSignal(SignalName.FinishedCreating, InternalName);
        }

        public void Enable()
        {
            if (Instance == null)
            {
                GD.PrintErr($"Enable error for scene {InternalName}: No instance exists.");
                return;
            }

            Instance.ProcessMode = Node.ProcessModeEnum.Inherit;
        }

        public void Disable()
        {
            if (Instance == null)
            {
                GD.PrintErr($"Disable error for scene {InternalName}: No instance exists.");
                return;
            }

            Instance.ProcessMode = Node.ProcessModeEnum.Disabled;
        }

        public void Remove()
        {
            Instance?.QueueFree();
            Instance = null;
        }

        public new void Dispose()
        {
            Resource?.Dispose();
            Instance?.QueueFree();

            Resource = null;
            Instance = null;
        }

        internal void OnLoaded(Scene scene, PackedScene resource)
        {
            if (scene.InternalName == InternalName && resource != null)
            {
                Resource = resource;
                EmitSignal(SignalName.FinishedLoading, InternalName);
            }
        }
    }
}