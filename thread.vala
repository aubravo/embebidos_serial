async double do_calc_in_bg(double val) throws ThreadError {
    SourceFunc callback = do_calc_in_bg.callback;
    double[] output = new double[1];

    // Hold reference to closure to keep it from being freed whilst
    // thread is active.
    ThreadFunc<void*> run = () => {
        // Perform a dummy slow calculation.
        // (Insert real-life time-consuming algorithm here.)
        double result = 0;
        for (int a = 0; a<10000000; a++)
            result += val * a;

        // Pass back result and schedule callback
        output[0] = result;
        Idle.add((owned) callback);
        return null;
    };
    new Thread<void*>.try(run, false);

    // Wait for background thread to schedule our callback
    yield;
    return output[0];
}

void main(string[] args) {
    var loop = new MainLoop();
    do_calc_in_bg.begin(0.001, (obj, res) => {
            try {
                double result = do_calc_in_bg.end(res);
                stderr.printf(@"Result: $result\n");
            } catch (ThreadError e) {
                string msg = e.message;
                stderr.printf(@"Thread error: $msg\n");
            }
            loop.quit();
        });
    loop.run();
}