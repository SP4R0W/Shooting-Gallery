using Godot;

namespace ComposerLib
{
    public partial class CreateSettings : Resource
    {
        public Node SceneParent {get; set;} = null;
        public bool DisableProcessing {get; set;} = false;
    }

    public partial class LoadSettings : CreateSettings
    {
        public bool InstantCreate {get; set;} = false;
        public bool UseSubthreads {get; set;} = false;
        public ResourceLoader.CacheMode CacheMode {get; set;} = ResourceLoader.CacheMode.Reuse;
    }

    public partial class AddSettings : LoadSettings
    {
        public bool InstantLoad {get; set;} = false;
    }

    public partial class ComposerSettings : AddSettings
    {

    }
}