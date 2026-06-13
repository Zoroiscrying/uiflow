using Godot;

namespace UIFlow.Utils
{
    /// <summary>
    /// Animation presets for common UI interactions.
    /// </summary>
    public static class UIFlowAnimPresets
    {
        public static Tween HoverScale(Control node, float scaleTo = 1.05f, float duration = 0.15f)
        {
            return UIFlowAnimator.AnimateRaw(node, "scale", node.Scale, new Vector2(scaleTo, scaleTo), duration);
        }

        public static Tween HoverReset(Control node, float duration = 0.15f)
        {
            return UIFlowAnimator.AnimateRaw(node, "scale", node.Scale, Vector2.One, duration);
        }

        public static Tween PressDown(Control node, float scaleTo = 0.95f, float duration = 0.1f)
        {
            return UIFlowAnimator.AnimateRaw(node, "scale", node.Scale, new Vector2(scaleTo, scaleTo), duration, Tween.EaseType.In, Tween.TransitionType.Quad);
        }

        public static Tween PressUp(Control node, float duration = 0.1f)
        {
            return UIFlowAnimator.AnimateRaw(node, "scale", node.Scale, Vector2.One, duration, Tween.EaseType.Out, Tween.TransitionType.Back);
        }

        public static Tween Shake(Control node, float intensity = 8f, float duration = 0.4f, float decay = 0.8f)
        {
            var tween = node.CreateTween();
            var originalPos = node.Position;
            float currentIntensity = intensity;

            for (int i = 0; i < 4; i++)
            {
                var offset = new Vector2(
                    (float)GD.RandRange(-currentIntensity, currentIntensity),
                    (float)GD.RandRange(-currentIntensity, currentIntensity)
                );
                tween.TweenProperty(node, "position", originalPos + offset, duration / 4f);
                currentIntensity *= decay;
            }
            tween.TweenProperty(node, "position", originalPos, duration / 4f);
            return tween;
        }

        public static Tween Pulse(Control node, float scaleTo = 1.1f, float duration = 0.3f)
        {
            var tween = node.CreateTween();
            tween.TweenProperty(node, "scale", new Vector2(scaleTo, scaleTo), duration / 2f).SetEase(Tween.EaseType.Out);
            tween.TweenProperty(node, "scale", Vector2.One, duration / 2f).SetEase(Tween.EaseType.In);
            return tween;
        }

        public static Tween PulseAlpha(Control node, float minAlpha = 0.3f, float duration = 0.6f)
        {
            var tween = node.CreateTween();
            tween.TweenProperty(node, "modulate:a", minAlpha, duration / 2f);
            tween.TweenProperty(node, "modulate:a", 1f, duration / 2f);
            return tween;
        }

        public static Tween SlideInLeft(Control node, float distance = 200f, float duration = 0.3f)
        {
            return UIFlowAnimator.AnimateRaw(node, "position:x", node.Position.X - distance, node.Position.X, duration, Tween.EaseType.Out, Tween.TransitionType.Back);
        }

        public static Tween SlideInRight(Control node, float distance = 200f, float duration = 0.3f)
        {
            return UIFlowAnimator.AnimateRaw(node, "position:x", node.Position.X + distance, node.Position.X, duration, Tween.EaseType.Out, Tween.TransitionType.Back);
        }

        public static Tween SlideInBottom(Control node, float distance = 200f, float duration = 0.3f)
        {
            return UIFlowAnimator.AnimateRaw(node, "position:y", node.Position.Y + distance, node.Position.Y, duration, Tween.EaseType.Out, Tween.TransitionType.Back);
        }

        public static Tween FadeIn(Control node, float duration = 0.2f)
        {
            return UIFlowAnimator.AnimateRaw(node, "modulate:a", 0f, 1f, duration);
        }

        public static Tween FadeOut(Control node, float duration = 0.2f)
        {
            return UIFlowAnimator.AnimateRaw(node, "modulate:a", 1f, 0f, duration);
        }

        /// <summary>
        /// Staggered fade-in for children of a container.
        /// </summary>
        public static UIFlowSequencer StaggerFadeIn(Node parent, float duration = 0.2f, float delay = 0.05f)
        {
            var seq = UIFlowAnimator.Sequencer();
            foreach (var child in parent.GetChildren())
            {
                if (child is Control ctrl)
                {
                    ctrl.Modulate = new Color(ctrl.Modulate.R, ctrl.Modulate.G, ctrl.Modulate.B, 0f);
                    seq.Add(ctrl, UIFlowTweenProp.Prop.ModulateA, 0f, 1f, duration).Delay(delay);
                }
            }
            return seq;
        }

        /// <summary>
        /// Staggered slide-in for children of a container.
        /// </summary>
        public static UIFlowSequencer StaggerSlideIn(Node parent, float distance = 50f, float duration = 0.3f, float delay = 0.05f)
        {
            var seq = UIFlowAnimator.Sequencer();
            foreach (var child in parent.GetChildren())
            {
                if (child is Control ctrl)
                {
                    seq.Add(ctrl, UIFlowTweenProp.Prop.PositionY, ctrl.Position.Y + distance, ctrl.Position.Y, duration).Delay(delay);
                }
            }
            return seq;
        }
    }
}
